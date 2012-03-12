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

  class CellHelper < Prawn::Table::Cell::Text

    def initialize cell, options={}
      @pdf = cell.instance_variable_get('@pdf')
      @type = options[:type] || :text
      super @pdf,cell.instance_variable_get('@point'),{ :content => cell.instance_variable_get('@content') }
    end

    def width val=nil
      if val
        self.width = val
        self
      else
        super()
      end
    end

    def draw_content
      if @type == :field
        x = -5.25 # FIXME: guesswork
        y = @pdf.cursor + padding[1] - (@pdf.font.line_gap + @pdf.font.descender)/2 + 3 # FIXME: guesswork
        w = spanned_content_width + FPTolerance + padding[2] + padding[3]
        h = @pdf.font.height + padding[0] + padding[1]

        old = @pdf.fill_color
        @pdf.fill_color = 'ffffff'
        @pdf.rectangle [x, y], w, h
        @pdf.fill
        @pdf.fill_color = old

        @pdf.stroke_line([x,   y],  [w+x, y])
        @pdf.stroke_line([w+x, y],  [w+x, y-h])
        @pdf.stroke_line([w+x, y-h],[x,   y-h])
        @pdf.stroke_line([x,   y-h],[x,   y])
      end

      super
    end

    def inspect
      "<CellHelper \"#{content}\">"
    end

  end

end
