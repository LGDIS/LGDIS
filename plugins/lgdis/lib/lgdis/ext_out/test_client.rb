# -*- encoding: utf-8 -*-
require_relative 'commons_client'
#NOTE: server URL below have to point to a address where commons web server processis running.
#      in other word, IP address of non-router (icluding virtualizer router).
server    = "http://192.168.43.186/"

# endpoint= 'http://0.0.0.0/commons/subscriber/soap/testservice.example.com/'
endpoint= server + "commons/subscriber/soap/testservice.example.com/"
client = CommonsClient.new('wsdl/MQService.wsdl', endpoint,'http://soap.publiccommons.ne.jp/')
client.set_auth('user1@example.com','password')
# data = REXML::Document.new(open('sample/1_ev_01_01.xml'))
data = REXML::Document.new(open('adsoltestbest.xml'))
client.send(data)

