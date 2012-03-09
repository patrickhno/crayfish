# Copyright (c) 2012 Bingoentrepenøren AS
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

require 'erubis'

module Crayfish
  module ActionView

    def render *args
      if @branch_level
        @branch_level += 1
        super
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

      def paint template
        begin
          erb = Erubis::Eruby.new(template,:bufvar=>'@_out_buf')
          erb.evaluate(self)
        rescue => e
          no = 0
          ::Rails.logger.debug erb.src.split("\n").map{ |line| no+=1; "#{no}: #{line}" }.join("\n")
          ::Rails.logger.debug e.message
          ::Rails.logger.debug e.backtrace.join("\n")
        end
        @pdf.render if @branch_level == 0
      end

      def flush paint=true
        buf = @_out_buf || ''
        @pdf.text buf if paint
        @_out_buf = ''
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

      def form *args, &block
        flush
        if block_given?
          pdf = CrayForm.new(self,@pdf)
          block.call pdf
          pdf.draw @_out_buf
        else
          form    = args[0] || ''
          options = args[1] || {}

          pdf = CrayForm.new(self,@pdf,options.merge(:span => /\|/, :element => /%c{(?<content>[^}]*)}/))
          pdf.heading options[:title] if options[:title]
          pdf.send(:form_body,form,options)
          pdf.draw @_out_buf
        end
        @_out_buf = ''
      end

      def table *args, &block
        if block_given?
          flush

          pdf = CrayTable.new(self,@pdf)
          block.call pdf
          pdf.draw @_out_buf
        else
          flush
          @pdf.table *args
        end
      end

      def html *args, &block
        raise "hell" unless block_given?
        flush
        html = CrayHtml.new(self,@pdf)
        block.call html
        html.draw @_out_buf
        flush false
      end

  end
end

