# -*- coding: utf-8 -*-
# Управление скачиванием файлов.
require 'rack/utils'

class DownloadApp
  def initialize(app)
    @app = app
  end


  def call(env)
    case env["PATH_INFO"]

   # Скачивание файл
   # если метод запроса HEAD - то это запрос на метаданные (размер файла, ...)
   # если метод запроса GET - то этот запрос на скачивание файла
   # параметры в url - id ProductLink
   # о запросе потока мы узнаем по наличию параметра env['HTTP_RANGE']

    when /^\/product_downloads/
      begin
        # получаем запись о ссылке скачивания
        @link_file_id =  /(\w{32})/.match(env["PATH_INFO"])
        @link_file = ProductLink.find_by_link_file(@link_file_id.to_s)
        request = Rack::Request.new(env)
	puts "нашли #{@link_file.id}"


        # Проверяем что запись найдена
        # Проверяем что время жизни ссылки не истекло
        # Проверяем что ип адресс совпадает с адресом клиента

        raise "can't find link" unless @link_file
        raise "link is expired" if @link_file.expired?
        @link_file.request = request

=begin
FIXME всё это не работает - но фактически исправляется в две строчки
кто найдет - молодец :)
        case env["REQUEST_METHOD"]

        when /HEAD/
          # Запрос метаданных
          # нужно отдать метаданные чтоб менеджеры загрузок нормально работали
          # метаданные можно отдавать если ссылка открыта для скачивания или скачивание было приостановлено

          if @link_file.open? || @link_file.pause?
            @headers = @link_file.user.blank? ? set_headers_for_stream(@link_file) : set_heades(@link_file)
            [200, @headers, "ok!"]
          else
            raise "Not found"
          end

        when /GET/
          # запрашивают файл
          if env['HTTP_RANGE'] =~ /bytes=(\d+)-(\d*)/ then
            # запрашивают часть файла
            # часть файла можно отдавать если ссылка нах-ся состоянии
            # :downloadable - файл качается или  :pause - скачивание приостановлено
            # также проверяем не превышен ли лимит потоков
            # после того как поток был выделен нужно записать в ссылку что выделен еще один поток
            @from_byte  = $1
            @to_byte = $2 unless $2.nil?

            case
            when @link_file.pause? && @link_file.downloading! # файл на паузе и можно возобновить скачивание

              @headers = set_heades(@link_file).
                merge!({
                         'Content-Range' => "bytes #{@from_byte}-#{@to_byte}/#{@link_file.file_size.to_s}",
                         'Content-Length' => "#{@to_byte.to_i - @from_byte.to_i + 1}",
                         'X-Accel-Redirect' => "/#{@link_file_id.to_s}#{@link_file.file_path.to_s}"
                       })
              [206, @headers, "ok!"]

            when @link_file.downloadable? && @link_file.add_new_stream # файл закачиваеться и можно отдать новый поток

              @headers = set_heades(@link_file).
                merge!({
                         'Content-Range' => "bytes #{@from_byte}-#{@to_byte}/#{@link_file.file_size.to_s}",
                         'Content-Length' => "#{@to_byte.to_i - @from_byte.to_i + 1}",
                         'X-Accel-Redirect' => "/#{@link_file_id.to_s}#{@link_file.file_path.to_s}"
                       })
              [206, @headers, "ok!"]

            else # левый запрос
              raise "Limit stream"
            end


          else

            # запрашивают целиком файл
            # файл можно отдать если ссылка имеет статус открыт (:open)
            # если файла еще нет во временной папке нужно его запросить
            # после того как файл был отдан на скачивание нужно установить статус ссылки как скачиваемый

            if @link_file.downloading! # если ссылка может быть переведена в состояние "файл скачиваеться"
puts "нашли 2 #{@link_file.id}"

              unless @link_file.user.blank? # определен пользователь
puts "нашли 3 #{@link_file.id}"
                @headers = set_heades(@link_file).
                  merge!({'X-Accel-Redirect' => "/#{@link_file_id.to_s}#{@link_file.file_path.to_s}" })
puts @headers
              else # пользователь не зарегистрирован
                @headers = set_headers_for_stream(@link_file).
                  merge!({ 'X-Accel-Redirect' => "/#{@link_file_id.to_s}#{@link_file.file_path.to_s}"})
puts @headers
              end

              [200, @headers, "ok!"]
            else
              raise 'Can`t change state to download'
            end
          end

        else #если другими методами то говорим о ошибке
          raise "Bad request"
        end
=end
      rescue => ex
        log ex.message
        if @link_file && @link_file.product_download
          download_link = @link_file.product_download.attachment.url.to_s
          log "файл найден - перенаправляем на страницу скачивания"
          log "url : #{download_link}"
          [206, {'X-Accel-Redirect'=> download_link }, ['Redirecting...']]
        else
          log "файл не найден - перенаправляем на главную страницу"
          [301, {'Location'=> '/' }, ['Redirecting...']]
        end
      end
    else
      @app.call(env)
    end
  end

  private

  def set_heades(link_file)
    {
      'Accept-Ranges' => 'bytes',
      'Content-Length' => link_file.file_size.to_s,
      'Content-Disposition' =>  "attachment; filename=#{link_file.file_name}",
      'Content-Type' => link_file.content_type.to_s,
      'X-Accel-Limit-Rate' => link_file.speed.to_s,
      "Content-Transfer-Encoding" => 'binary'
    }
  end
  def set_headers_for_stream(link_file)
    {
      'Content-Length' => link_file.file_size.to_s,
      'Content-Disposition' => "attachment; filename=\"#{link_file.file_name}\"",
      'Content-Type' => link_file.content_type.to_s,
      'X-Accel-Limit-Rate' => link_file.speed.to_s
    }
  end

  def log message
    Rails.logger.error [" [ Download file: ] ", message].join
  end
end
