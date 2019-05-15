#!/usr/bin/env ruby

###########################################
# notify_slack.rb                         #
# May 12th, 2019                          #
#                                         #
# @freak4pc | shai.mishali@gett.com       #
#                                         #
# This script pushes a slack status       #
# update to #designsystem about a Design  #
# System generation step, based on some   #
# runtime flags.                          #
###########################################

require_relative "lib/arguments"
require 'net/http'
require 'json'

include Arguments

args = Arguments.parse(ARGV)

if !args.key?(:platform) then
    print("Missing platform flag")
    exit 1
end

if !ENV.key?('BITRISE_BUILD_URL') || !ENV.key?('BITRISE_BUILD_TRIGGER_TIMESTAMP') || !ENV.key?('BITRISE_BUILD_NUMBER') then
    print("Missing CI Environment")
    exit 1
end

build_number = ENV['BITRISE_BUILD_NUMBER']
build_url = ENV['BITRISE_BUILD_URL']
build_time = Time.now.getlocal('+03:00')

if args.key?(:started) then
    color = "#FFB640"
    message = "#{args[:platform]} Style Guide Generation is ongoing"
    build_status = "Started"
    additional_field_title = "Build"
    additional_field_value = "<#{build_url}|##{build_number}>"
elsif args.key?(:nodiff) then
    color = "#DBE0E3"
    message = "No changes detected between Style Guide and Code"
    build_status = "Aborted"
    additional_field_title = "Build"
    additional_field_value = "<#{build_url}|##{build_number}>"
elsif args.key?(:error) then
    color = "#F45D56"
    message = args[:error]
    build_status = "Failed"
    additional_field_title = "Build"
    additional_field_value = "<#{build_url}|##{build_number}>"
elsif args.key?(:success) then
    color = "#8DD273"
    message = "#{args[:platform]} Style Guide successfully generated"
    build_status = "Successful"
    pr_url = args[:success]
    pr_number = pr_url.split("/").last
    additional_field_title = "Pull Request"
    additional_field_value = "<#{pr_url}|##{pr_number}>"
else
    puts("Make sure you set either --started, --nodiff, --error=[message] or --success=[pull_request_url].")
    exit(1)
end

uri = URI.parse("https://hooks.slack.com/services/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")
body = {
    "attachments" => [
        {
            "fallback" => message,
            "color" =>  color,
            "fields" => [
                {
                    "title" => "Design System Generation #{build_status}",
                    "value" => message,
                    "short" => false
                },
                {
                    "title" => "Platform",
                    "value" => args[:platform],
                    "short" => true
                },
                {
                    "title" => "Time",
                    "value" => "#{build_time}",
                    "short" => true
                },
                {
                    "title" => additional_field_title,
                    "value" => additional_field_value,
                    "short" => true
                }
            ]
        }
    ]
}

req = Net::HTTP::Post.new(uri.to_s)
req['Content-Type'] = 'application/json'
req.body = body.to_json
http = Net::HTTP.new(uri.host, uri.port).tap do |http|
    http.use_ssl = true
end
res = http.request(req)