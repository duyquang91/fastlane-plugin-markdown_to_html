#
#  markdown_to_html_action.rb
#
#  Created by Steve Dao on 17/3/20.
#  Copyright © 2020 NE CoE. All rights reserved.
#

require 'fastlane/action'
require 'json'
require 'net/http'
require 'uri'
require_relative '../helper/markdown_to_html_helper'

module Fastlane
  module Actions
    class MarkdownToHtmlAction < Action
      def self.run(params)
        # Variables
        files = params[:files]
        output = params[:output] || "/"
        github_access_token = params[:github_access_token] || ENV['GITHUB_ACCESS_TOKEN']

        sh("cd ..")

        files.each do |file|
          generate_html(file, output, github_access_token)
        end
      end

      def self.description
        "This plugin convert a markdown file format to a html file format"
      end

      def self.authors
        ["Steve"]
      end

      def self.return_value
        # If your method provides a return value, you can describe here what it does
      end

      def self.details
        # Optional:
        "This plugin convert a markdown file format to a html file format supported by github API"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :files,
                               description: "An array of markdown files to convert",
                                  optional: false,
                                      type: Array),
          FastlaneCore::ConfigItem.new(key: :output,
                               description: "The output folder where generated html files would be saved",
                                  optional: true,
                                      type: String,
                             default_value: "/"),
          FastlaneCore::ConfigItem.new(key: :github_access_token,
                                  env_name: "GITHUB_ACCESS_TOKEN",
                               description: "Github Access Token to fetch the html from Github API",
                                  optional: true,
                                      type: String)
        ]
      end

      def self.is_supported?(platform)
        # Adjust this if your plugin only works for a particular platform (iOS vs. Android, for example)
        # See: https://docs.fastlane.tools/advanced/#control-configuration-by-lane-and-by-platform
        #
        # [:ios, :mac, :android].include?(platform)
        true
      end

      # Generating html from Github API
      def self.generate_html(file, output, github_access_token)
        fileName = file.include?(".md") ? file.delete(".md") : file
        puts("Generating html file from #{fileName} ...")
        input = File.read("#{fileName}.md")
        input = input.to_json

        uri = URI.parse("https://api.github.com/markdown")
        request = Net::HTTP::Post.new(uri)
        request.content_type = "text/html"
        request['Authorization'] = "Bearer #{github_access_token}" if github_access_token
        request.body = "{\"text\": #{input}}"

        req_options = {
          use_ssl: uri.scheme == "https"
        }

        response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
          http.request(request)
        end

        # Write to File
        outputFile = output[-1] == "/" ? output : "#{output}/"
        File.open("#{output}#{fileName}.html", "w") do |f|
          body = response.body
          f.write("<!DOCTYPE html> \n") unless body.include?("<!DOCTYPE html>")
          f.write(body)
        end
      end
    end
  end
end
