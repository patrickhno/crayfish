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
  module Rails

    class PDF
      
      attr_reader :options

      def initialize(controller)
        controller_options = (controller && controller.respond_to?(:options)) ? controller.send(:options) || {} : {}
        @options = Crayfish::ActionController.options.merge(Hash[*controller_options.map{ |k,v| [k.to_sym,v] }.flatten])

        if controller && controller.respond_to?(:response)
          if options[:html]
            controller.response.content_type ||= Mime::HTML
          else
            controller.response.content_type ||= Mime::PDF
          end
        end

        inline = options[:inline] ? 'inline' : 'attachment'
        filename = options[:filename] ? "filename=#{options[:filename]}" : nil
        controller.headers["Content-Disposition"] = [inline,filename].compact.join(';') if controller && controller.respond_to?(:headers)
      end

    end

  end
end



