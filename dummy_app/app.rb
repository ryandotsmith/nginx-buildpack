#!/usr/bin/env ruby

require 'sinatra'

class Pumatra < Sinatra::Base
  get '/' do
    return 'It works! This is the dummy_app: minimal puma and sinatra web app.'
  end
end

if __FILE__ == $0
  Pumatra.run!
end
