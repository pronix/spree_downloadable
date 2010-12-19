class SpreeDownloadableHooks < Spree::ThemeSupport::HookListener
  # заголовок колонки downloadable в таблице продуктов
  insert_after :admin_products_index_headers do
    "<th><%= t('downloadable') %></th>"
  end

  # значения в колонке downloadable в таблице продуктов
  insert_after :admin_products_index_rows do
    "<td><%= (!product.product_download.nil?).to_s %></td>"
  end

  # ссылка на скачиваемые файлы для товара
  insert_after :admin_product_tabs do
    "<li<%= raw(' class=\"active\"') if current == 'Downloadables' %>>
     <%= link_to t('downloads'), admin_product_product_downloads_path(@product) %></li>"
  end
end
