# Copyright (c) 2012 Bingoentreprenøren AS
# Copyright (c) 2012 Patrick Hanevold
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module Crayfish
  module ActionView

    def render *args
      if @branch_level
        @branch_level += 1
        stack = @output_buffer
        @output_buffer = ::ActionView::OutputBuffer.new
        super
        @output_buffer = stack
        @branch_level -= 1
      else
        super
      end
    end

    private

      def setup
        @branch_level ||= 0
        if @branch_level == 0
          @options = Crayfish::Rails::PDF.new(controller).options
          @pdf = Prawn::Document.new(@options[:prawn])
        end
      end

      def output_buffer
        @output_buffer ||= ::ActionView::OutputBuffer.new
      end

      def paint template,raw=false
        begin
          html = raw ? template : eval(template)
          Html.new(self,@pdf).draw(html)
        rescue => e
           no = 0
           ::Rails.logger.debug template.split("\n").map{ |line| no+=1; "#{no}: #{line}" }.join("\n")
           ::Rails.logger.debug e.message
           ::Rails.logger.debug e.backtrace.join("\n")
        end
        @pdf.render if @branch_level == 0 and !raw
      end

      def flush paint=true
        buf = @output_buffer.to_s || ''
        paint(buf,true) if paint
        @output_buffer = ::ActionView::OutputBuffer.new
        buf
      end

      def method_missing(meth, *args, &block)
        if @pdf.respond_to?(meth)
          flush
          @pdf.send(meth,*args)
        else
          super
        end
      end

  end
end

