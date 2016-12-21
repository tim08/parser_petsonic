# подключаем необходимые либы
require 'open-uri'
require 'nokogiri'
require 'csv'

# получаем данные от пользователя из параметров
# пример запуска ruby parser.rb http://www.petsonic.com/es/perros/snacks-y-huesos-perro/hobbit-half-barritas-redonda-de-ternera products.csv

# линка на категорию
url_category = ARGV.first
# имя файла в который будем записывать данные
file_name = ARGV.last

# парсим страницу с товарами
main_category_page = Nokogiri::HTML(open(url_category))

# разбиваем данные на отдельные товары
list_products = main_category_page.css('div.ajax_block_product')

# указываем пустой массив(в него будем записывать урлы на товары)
all_products_url = []

# проходимся по всем товарам
list_products.each do |product|
  # парсим урл товара и добавляем в массив
  all_products_url << product.css('div.left-block').css('a.product_img_link').at('a')['href']
end

# открываем файл csv и указываем обозначения столбцов
CSV.open(file_name, "wb") do |csv_line|
  csv_line << ['Название', 'Цена', 'Изображение']

  # теперь проходимся оп массиву с урлами на товары
  all_products_url.each do |product_url|

    # парсим страницу с товаром
    product_page = Nokogiri::HTML(open(product_url))

    # название продукта
    product_name = product_page.css('div.product-name').css('h1 > text()').to_s

    # изображение продукта
    product_img = product_page.css('span#view_full_size').css('img#bigpic').at('img')['src']

    #  парсим вариации весовки товара
    attribute_product_list = product_page.css('fieldset.attribute_fieldset').css('ul.attribute_labels_lists')

    # проходимся по каждой весовке
    attribute_product_list.each do |attr|
      # весовка продукта
      product_pre_packing = attr.xpath('//span[@class="attribute_name"]').text

      # цена продукта для данной весовки
      product_price = attr.xpath('//span[@class="attribute_price"]')

      # собираем строку с информацией о продукте по шаблону из задания
      full_info = ["#{product_name} - #{product_pre_packing}", product_price, product_img]

      # пишем собранные данные в наш файл
      csv_line << full_info
    end

  end
end
