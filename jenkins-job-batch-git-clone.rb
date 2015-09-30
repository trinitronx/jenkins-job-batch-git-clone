#!/usr/bin/env ruby
# encoding: utf-8

require 'rubygems'
require 'net/http'
require 'jenkins_api_client'
require 'addressable/uri'
require 'pp'

@jenkins_user  = ENV['JENKINS_USER'] || nil
@jenkins_password = ENV['JENKINS_PASSWORD'] || nil
@jenkins_host  = ENV['JENKINS_HOST'] || 'jenkins'
@jenkins_port = ENV['JENKINS_PORT'] || '80'
@jenkins_job_filter = ENV['JENKINS_JOB_FILTER'] || ''
@git_clone_fqdn = ENV['GIT_CLONE_FQDN'] || nil
@git_clone_user = ENV['GIT_CLONE_USER'] || nil
@git_clone_dir = ENV['GIT_CLONE_DIR'] || '/tmp/src'

@jenkins_job_git_url_list = []

if ENV['JENKINS_DEBUG']
  printf "%42s = %s\n", "\033[1;32mJENKINS_HOST\033[0m", @jenkins_host
  printf "%42s = %s\n", "\033[1;32mJENKINS_PORT\033[0m", @jenkins_port
end

class UnspecifiedParameters < RuntimeError
end

if @jenkins_user.nil? || @jenkins_password.nil?
  printf "%s", "\033[1;31mERROR:\033[0m No JENKINS_USER or JENKINS_PASSWORD given."
  raise UnspecifiedParameters, "Required Environment variables not set: No JENKINS_USER or JENKINS_PASSWORD given."
end

@client = JenkinsApi::Client.new(:server_ip => @jenkins_host, :server_port => @jenkins_port,
         :username => @jenkins_user, :password => @jenkins_password)

# For each job matching @jenkins_job_filter, search for git clone URI
# If found, add to git_repo_url_list
@client.job.list( @jenkins_job_filter ).each do |jenkins_job|
  if ! @client.job.get_config( jenkins_job ).scan( /.*git.*/ ).empty?
    config_xml = Nokogiri::XML( @client.job.get_config(jenkins_job) )
    jenkins_job_git_url = config_xml.xpath("//scm[contains(@class,'git')]/userRemoteConfigs/hudson.plugins.git.UserRemoteConfig/url").text
    if jenkins_job_git_url
      @jenkins_job_git_url_list.push Addressable::URI.parse( jenkins_job_git_url )
    end

    if ENV['JENKINS_DEBUG']
      puts "Jenkins job '#{jenkins_job}':\n\n"
      puts config_xml.xpath("//scm[contains(@class,'git')]/userRemoteConfigs/hudson.plugins.git.UserRemoteConfig/url")
      puts "\n\n"
      ## If repoTag contains a literal '$', we want to know where this variable comes from
      puts "Git URL:"
      puts jenkins_job_git_url
      puts "Clone URL Construction:"
      my_uri = @jenkins_job_git_url_list.last
      unless my_uri.host.include? '.'
        my_uri.host << @git_clone_fqdn
      end
      puts "git clone ssh://#{ENV['GIT_CLONE_USER'] + '@' if ENV['GIT_CLONE_USER']}#{my_uri.host}:#{my_uri.port}#{my_uri.path}"
      puts "Current Build Number:"
      puts @client.job.get_current_build_number( jenkins_job )
    end
  end
end


puts "Checking out git repos..."
@jenkins_job_git_url_list.each do |my_uri|
  unless my_uri.host.include? '.'
    my_uri.host << @git_clone_fqdn
  end
  FileUtils.mkdir_p @git_clone_dir
  FileUtils.cd(@git_clone_dir) do
    system( "git clone ssh://#{ENV['GIT_CLONE_USER'] + '@' if ENV['GIT_CLONE_USER']}#{my_uri.host}:#{my_uri.port}#{my_uri.path}" )
  end
end
