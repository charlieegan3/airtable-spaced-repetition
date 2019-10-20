FROM  ruby:2.3-slim-jessie

RUN gem install dotenv

COPY notify.rb /bin/notify.rb

CMD ["dotenv", "-f", "/etc/config/env", "./bin/notify.rb"]
