require 'aasm'
class ProductLink < ActiveRecord::Base
  attr_accessor :request
  belongs_to :product
  belongs_to :order
  include AASM

  belongs_to :product_download
  belongs_to :order
  belongs_to :product

  validates_uniqueness_of :link_file #ссылка должна быть уникальна

  aasm_column :status
  aasm_initial_state :open

  aasm_state :open                                          # ссылка открыта для скачивания
  aasm_state :downloadable, :enter => :init_downloadable    # файл качаеться
  aasm_state :pause       , :enter => :decrement_counter    # скачивание приостановлено
  aasm_state :downloaded  , :enter => :complete_downloaded  # файл скачен


  aasm_event :downloading do # переходит в состояние "файл качаеться"
    transitions :to => :downloadable, :from => [:open, :pause] , :guard => :allowed_to_download?
  end

  aasm_event :complete do  # переходит в сосание "файл скачан"
    transitions :to => :downloaded, :from => [:downloadable]
  end

  aasm_event :suspended do  # переходит в состояние "скачивание приостановлено"
    transitions :to => :pause, :from => [:downloadable]
  end

  before_validation_on_create :auto_fill

  # заполняем необходимые поля для линка на скачивание файла перед валидацией
  def auto_fill
    self.file_name = product_download.attachment_file_name
    self.file_path = product_download.attachment.path
    self.file_size = product_download.attachment.size
    self.content_type = product_download.attachment.content_type
    self.current_count_streams = 0

    self.expire = (Time.now + 1.days).end_of_day
    self.concurenc_download =  1

    @word= Array.new(100){ ['0'..'9','a'..'z','A'..'Z'].map{ |r| r.to_a }.
      flatten[ rand( ['0'..'9','a'..'z','A'..'Z'].map{ |r| r.to_a }.flatten.size ) ] }.join

    self.link_file = Digest::MD5.hexdigest([self.to_s, Time.now.to_i,@word].join)

  end

  # Этот метод срабатывает при начале скачивания файла
  # Здесь можно добавлять условия по которым запрещено скачивать файл
  # Скачивать будет разрешено если этот метод вернет true
  # ----------------------------------------------------------------

  def allowed_to_download?
    # сюда добавляем сами условия
  end

  # срок действия ссылки истек
  def expired?
    expire <= Time.now
  end

  # при переходе статуса ссылки  в "качаеться"
  # в потоки добавляем основной поток
  # увеличиваем счетчик кол-во качаемых файлов с данного ип адреса
  def init_downloadable
    transaction do
      self.current_count_streams = 1
    end
  end


  # Файл скачан
  # нужно увеличить счетчик скачивание файла
  def complete_downloaded

    if self.bytes_sent.to_i >= self.file_size.to_i
      product_download.inc_downloaded_times
    end

    product_download.save
  end

  # добавляем новый поток
  def add_new_stream
    transaction do
      self.current_count_streams = (self.current_count_streams||0) + 1
      save
    end
  end

  # поток завершен
  # завершение потока возможно по след причинам:
  # 1 - все скачано по данному потоку
  # 2 - скачивание файла было прерванною или приостановлено
  # При завершение потока уменьшаем текущее кол-во используемых потоков,
  # увеличиваем кол-во отданных пользователю байтов
  # При условии что кол-во текущих потоков равно нулю и
  # кол-во отданных пользователю байт больше или равно размеру файла
  # то считаем что скачивание файла завершено и переводим ссылку в состояние :downloaded.
  # Если же кол-во текущих потоков равно нулю, а кол-во отданных байт меньше размера файла
  # то считаем что скачивание файла было приостановлено или отменено
  def close_stream(bytes_sent)
    transaction do
      self.current_count_streams = self.current_count_streams.to_i - 1
      self.bytes_sent = self.bytes_sent.to_i+ bytes_sent.to_i
      save
    end

    if self.current_count_streams.to_i == 0 &&
       (self.bytes_sent.nil? || self.bytes_sent.to_i >= self.file_size.to_i)
      complete! # скачивание завершено
    elsif self.current_count_streams.to_i == 0 &&
        self.bytes_sent.to_i < self.file_size.to_i
      suspended! # скачивание приостановлено
    end
  end
end

