#!/usr/bin/env ruby

require "json"
require "optparse"

$LOAD_PATH.unshift File.expand_path(".", "lib")

require "llsif_wake"

if __FILE__ == $PROGRAM_NAME
  options = {}

  OptionParser.new do |opts|
    opts.banner = "Usage: #{$PROGRAM_NAME} [options]"

    opts.on("-d", "--json-directory DIRECTORY", "Directory to search for JSON files") do |d|
      options[:json_directory] = d
    end

    opts.on("-o", "--output-directory DIRECTORY", "Directory to output processed JSON and HTML files") do |o|
      options[:output_directory] = o
    end

    opts.on_tail("-h", "--help", "Prints this help") do
      puts opts
      exit
    end
  end.parse!

  raise ArgumentError, "--json-directory is required" unless options[:json_directory]
  raise ArgumentError, "--output-directory is required" unless options[:output_directory]

  json_files = Dir[File.join(options[:json_directory], "**")]

  pb = ProgressBar.new(json_files.size)
  LlsifWake::Output.log "Parsing login info"

  login_info = json_files.map do |file_path|
    pb.increment!
    LlsifWake::Parser::Login.new(file_path).parse
  end.compact.max { |li| li[:fetched_on] }

  File.open(File.join(options[:output_directory], "login.json"), "w") { |f| f << JSON.generate(login_info) }

  pb = ProgressBar.new(json_files.size)
  LlsifWake::Output.log "Parsing member list"

  member_list = [].tap do |items|
    json_files.each do |file_path|
      items.concat(LlsifWake::Parser::MemberList.new(file_path).items)
      pb.increment!
    end
  end.uniq.sort

  pb = ProgressBar.new(json_files.size)
  LlsifWake::Output.log "Parsing present list"

  present_list = [].tap do |items|
    json_files.each do |file_path|
      items.concat(LlsifWake::Parser::PresentBox.new(file_path).items)
      pb.increment!
    end
  end.uniq.sort

  pb = ProgressBar.new(member_list.size + present_list.size)
  LlsifWake::Output.log "Fetching card information"

  card_list = (member_list + present_list).map do |ci|
    pb.increment!
    ci.card
  end.uniq.sort.inject({}) do |memo, card|
    memo.merge(card.id => card.as_json)
  end

  File.open(File.join(options[:output_directory], "cards.json"), "w") do |f|
    f << JSON.generate(card_list)
  end

  LlsifWake::Output.log "Fetching gained cards by date"

  instances_by_date = (member_list + present_list).sort_by do |ci|
    [ci.gained_at, ci.instance_id]
  end.group_by(&:id).map do |id, cis|
    card_list[id].merge(instances: cis.map(&:as_json))
  end

  File.open(File.join(options[:output_directory], "instances_by_date.json"), "w") do |f|
    f << JSON.generate(instances_by_date)
  end
end
