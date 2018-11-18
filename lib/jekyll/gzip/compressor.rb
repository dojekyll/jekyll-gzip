# frozen_string_literal: true

require 'jekyll/gzip/config'
require 'zlib'

module Jekyll
  ##
  # The main namespace for +Jekyll::Gzip+. Includes the +Compressor+ module
  # which is used to map over files, either using an instance of +Jekyll::Site+
  # or a directory path, and compress them using Zlib.
  module Gzip
    ##
    # The module that does the compressing using Zlib.
    module Compressor
      ##
      # Takes an instance of +Jekyll::Site+ and maps over the site files and
      # compressing them in the destination directory.
      # @example
      #     site = Jekyll::Site.new(site_config)
      #     Jekyll:Gzip::Compressor.compress_site(site)
      #
      # @param site [Jekyll::Site] A Jekyll::Site object that has generated its
      #   site files ready for compression.
      #
      # @return void
      def self.compress_site(site)
        site.each_site_file do |file|
          compress_file(file.destination(site.dest), zippable_extensions(site))
        end
      end

      ##
      # Takes a directory path and maps over the files within compressing them
      # in place.
      #
      # @example
      #     Jekyll:Gzip::Compressor.compress_directory("~/blog/_site")
      #
      # @param dir [Pathname, String] The path to a directory of files ready for
      #   compression.
      #
      # @return void
      def self.compress_directory(dir, site)
        extensions = zippable_extensions(site).join(',')
        files = Dir.glob(dir + "**/*{#{extensions}")
        files.each { |file| compress_file(file, extensions) }
      end

      ##
      # Takes a file name and compresses it using Zlib, outputting the gzipped
      # file under the name of the original file with an extra .gz extension.
      #
      # @example
      #     Jekyll::Gzip::Compressor.compress_file("~/blog/_site/index.html")
      #
      # @param file_name [String] The file name of the file we want to compress
      #
      # @return void
      def self.compress_file(file_name, extensions)
        return unless extensions.include?(File.extname(file_name))
        zipped = "#{file_name}.gz"
        Zlib::GzipWriter.open(zipped, Zlib::BEST_COMPRESSION) do |gz|
          gz.mtime = File.mtime(file_name)
          gz.orig_name = file_name
          gz.write IO.binread(file_name)
        end
      end

      private

      def self.zippable_extensions(site)
        site.config['gzip'] && site.config['gzip']['extensions'] || Jekyll::Gzip::DEFAULT_CONFIG['extensions']
      end
    end
  end
end
