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

module Crayfish
  class CrayForm < CrayContainer

    def initialize fish, pdf, options = {}
      @fish=fish
      @spans = []
      super
    end

    # Flush accumulated text and append a (prawn) element
    def append stuff, options={}
      buf = @fish.send(:flush,false)
      @spans << (options[:spans] || [])
      super
      #form_body(buf) if buf.strip != ''
      buf
    end

    def heading str
      append [form_body(str,:spacing => 0)]
    end

    # Draws the form in all its glory
    def draw text
      form_body(text,@options)

      allign_spans

      table = @pdf.make_table raw, :width => 540, :cell_style => { :padding => [0,0,0,0], :border_width => 1 }

      pdf.fill_color 'CCCCFF'
      pdf.fill { @pdf.rectangle [0, pdf.cursor], table.width, table.height }

      pdf.fill_color '000000'
      table.draw
    end

  private

    def allign_spans
      # group by span count
      # in the future we may want to group by span id's or paths to allow much more fine grained controll of span allignment
      groups = @spans.map{ |row| row.max }.uniq.select{ |cnt| cnt }
      i = -1
      indexed = @spans.map{ |span| i+=1; {:index => i, :row => raw[i] } }

      groups.each do |group_cnt|
        # all rows with group_cnt number of spans
        considder = indexed.select{ |row| @spans[row[:index]].max == group_cnt }.map{ |row| row[:index] }

        # the span width map
        width_map = considder.map do |index|
          spans  = @spans[index]
          row    = raw[index].first[:content]
          widths = row.row(0).columns(0..-1).map{ |cell| cell.natural_content_width }

          i = 0
          spans.map do |span_index|
            span = widths[i..span_index-1]
            i=span_index
            span.sum
          end
        end

        alligned_widths = width_map.transpose.map{ |col| col.max }

        # allign cells
        considder.each do |index|
          row_width = reminding_width = raw[index].first[:content].row(0).width
          raw[index].first[:content].row(0).columns(0..alligned_widths.size-1).each_with_index do |cell,i|
            cell.width = alligned_widths[i]
            reminding_width -= cell.width
          end
          # fit reminding cells in row
          # TODO: respect constraints!
          x = row_width-reminding_width
          w = reminding_width / raw[index].first[:content].row(0).columns(alligned_widths.size..-1).size
          raw[index].first[:content].row(0).columns(alligned_widths.size..-1).each do |cell|
            cell.x = x
            cell.width = w
            x += w
          end
        end
      end
    end

    def _text text,options = {}
      Crayfish::CellHelper.new(Prawn::Table::Cell.make(pdf, text), options)
    end

    def _field width=nil
      cell = _text('', { :type => :field })
      cell.width(width) if width
      cell
    end

    def _space width=nil
      cell = _text('')
      cell.width(width) if width
    end

    def form_body form,options = {}
      color = 'CCCCFF'

      space_width = 10

      lines = form.split("\n").map{ |line| line.strip }.select{ |line| line.size > 0 }
      return unless lines.size > 0

      spans_per_line = lines.map{ |line| line.split(tokens[:span]).size-1 }
      raise 'the number of spans must be the same on all lines' unless spans_per_line.uniq.size <= 1
      spans_per_line = spans_per_line.first

      span_table = lines.map{ |line| line.split(tokens[:span]) }

      # split text from fields in all spans
      table = span_table.map do |row|
        row.map do |span|
          span.split(tokens[:element]).zip(span.scan(tokens[:element])).flatten
        end
      end

      # translate each span into a subtable
      table.map! do |row|
        row.map do |span|
          pdf.make_table [ span.map{ |cell| cell =~ /^#{tokens[:element].source}$/ ? _field(cell.count(' ')*space_width) : _text(cell) } ],:cell_style => { :borders => [] }
        end
      end

      padding = options[:spacing] || (pdf.font.line_gap + pdf.font.descender)

      # note that the spans above are in sub-tables, we need adressable spans (like xpath) if we want to use them further
      # for now, pass a empty span list for this row (this form body is appended as a single row)
      append [pdf.make_table(table, :width => 540, :cell_style => {:padding => [padding,0,padding,0], :borders => [] })], :spans => []
    end

  end
end
