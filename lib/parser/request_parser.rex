# encoding : utf-8
#
# request_parser.rex
# lexical scanner definition for rex
# 

class RequestParser
macro
  BLANK         \s+

  R_METHOD      \A[A-Z]+[^\s]\s+    # метод запроса
  R_URI         \A\/\S+[^\s]\s+     # uri
  R_PROTOCOL    \AHTTP.*            # версия HTTP

  H_NAME        \A[\w+\-]+[^:]      # имя заголовка
  H_VALUE       \A:\s+.*$           # значение заголовка

rule
  {BLANK}

  {R_METHOD}    { [:METHOD,   text.strip] }
  {R_URI}       { [:URI,      text.strip] }
  {R_PROTOCOL}  { [:PROTOCOL, text.strip] }

  {H_NAME}      { [:H_NAME,  text.gsub('-', '_').upcase] }   
  {H_VALUE}     { [:H_VALUE, text.gsub(/:\s+/, '')] }

inner
end

