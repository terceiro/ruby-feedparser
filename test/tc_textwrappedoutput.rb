#!/usr/bin/ruby -w

$:.unshift File.join(File.dirname(__FILE__), '..', 'lib')

require 'test/unit'
require 'feedparser'

class TextWrappedOutputTest < Test::Unit::TestCase
  if File::directory?('test/source')
    SRCDIR = 'test/source'
    DSTDIR = 'test/textwrapped_output'
  elsif File::directory?('source')
    SRCDIR = 'source'
    DSTDIR = 'textwrapped_output'
  else
    raise 'source directory not found.'
  end
  Dir.foreach(SRCDIR) do |f|
    next if f !~ /.xml$/
    testname = 'test_' + File.basename(f).gsub(/\W/, '_')
    define_method(testname) do
      str = File::read(SRCDIR + '/' + f)
      chan = FeedParser::Feed::new(str)
      chanstr = chan.to_text(false, 72) # localtime set to false
      if File::exist?(DSTDIR + '/' + f.gsub(/.xml$/, '.output'))
        output = File::read(DSTDIR + '/' + f.gsub(/.xml$/, '.output'))
        if output != chanstr
          File::open(DSTDIR + '/' + f.gsub(/.xml$/, '.output.new'), "w") do |fd|
            fd.print(chanstr)
          end
          assert(
            false,
            [
              "Test failed for #{f}.",
              "  Check: diff -u #{DSTDIR + '/' + f.gsub(/.xml$/, '.output')}{,.new}",
              "  Commit: mv -f #{DSTDIR + '/' + f.gsub(/.xml$/, '.output')}{.new,}",
            ].join("\n")
          )
        end
      else
        File::open(DSTDIR + '/' + f.gsub(/.xml$/, '.output'), "w") do |f|
          f.print(chanstr)
        end
        assert(false, "Missing #{DSTDIR + '/' + f.gsub(/.xml$/, '.output')}. Writing it, but check manually!")
      end
    end
  end
end
