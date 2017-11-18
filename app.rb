#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/activerecord'

#=================================================

set :database, "sqlite3:barbershop.db"

class Client < ActiveRecord::Base
end

class Barbers < ActiveRecord::Base
end

class Contacts < ActiveRecord::Base
end

class Blog < ActiveRecord::Base
end

class Comment < ActiveRecord::Base
end

#==================================================


get '/' do
  @barbers = Barbers.order "created_at DESC"
  erb :index
end

get '/visit' do
  @master = Barbers.all
  erb :visit
end

post '/visit' do
  @error = ''
  errors = {
      "user_name" => "Введите имя",
      "user_phone" => "Введите телефон",
      "user_time" => "Введите время"
  }
  params.each_key do |key|
    if params[key].to_s == ""
      @error = @error + "#{errors[key]}" + "</br>"
    end
  end
  if @error != ''
    @master = Barbers.all
    return erb :visit
  end
  Client.create :name => params[:name_user], :phone => params[:user_phone], :datestamp => params[:user_time], :barber => params[:user_master], :color => params[:color]
  @message = "Вы успешно записаны на #{params[:user_time]}"
  #params.each_with_index { |value, index | @write_data[index] = value }
  erb :message
end

# написать письмо
get '/contacts' do
  erb :contacts
end

post '/contacts' do
  require "pony"
  @user_email = params[:user_email]
  @user_message = params[:user_message]
  my_mail = "kegz@mail.ru"
  password ="dshjljr" #неотображать вводимые символы
  sent_to = "kegz@mail.ru"
  message = @user_email + "\n \n" + @user_message

  hh = {
      :user_email => 'Введите правильный e-mail',
      :user_message => 'Введите текст сообщения',
  }
  @error = hh.select { |key, _| params[key] == "" }.values.join("</br>")
  if @error > ""
    erb :contacts
  else

    begin #обработка ошибок
      Pony.mail(
          {
              :subject => "С сайта BARBERSHOP",
              :body => message,
              :to => sent_to,
              :from => my_mail,

              :via => :smtp,
              :via_options => {
                  :address => 'smtp.mail.ru',
                  :port => '465',
                  :tls => true,
                  :user_name => my_mail,
                  :password => password,
                  :authentication => :plain
              }
          }
      )
      @message = "Успешно отправлено"
    rescue Net::SMTPAuthenticationError => error
      @message = " Ошибка аутентификации " + error.message.to_s
    rescue Net::SMTPFatalError => error
      @message = " Проверьте данные адресата " + error.message
        # puts "Не удалось отправить письмо"
    ensure
      #puts "Попытка отправки письма закончена"
    end #обработка ошибок
    Contacts.create :email => params[:user_email], :content => params[:user_message]
    erb :message
  end
end

get '/blog' do
  @blog = Blog.all
  erb :blog
end

get '/new' do
  erb :new
end

post '/new' do
  if params[:text_new_post].length <= 0
    @error = 'Введите текст'
    return erb :new
  end
  Blog.create "name" => params[:user_new_post], "content" => params[:text_new_post]
  redirect '/'
end

get '/details/:post_id' do
  @post = Blog.find(params[:post_id])
  @comment = Comment.all
  erb :details
end

post '/details/:post_id' do
  @error = ""
  params[:user_name] == "" ? @error = @error + "Введите ваше имя" : ''
  params[:user_comment] == "" ? @error = @error + "Введите комментарий" : ""
  if @error > ""
    return erb :details
  else
    Comment.create "name" => params[:user_name], "content" => params[:user_comment]
  end
  redirect "/details/#{params[:post_id]}"
end
