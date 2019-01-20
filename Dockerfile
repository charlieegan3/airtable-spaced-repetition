FROM  ruby:2.3-slim-jessie

COPY notify.rb /bin/notify.rb

CMD ./bin/notify.rb
