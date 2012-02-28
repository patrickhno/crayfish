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

class CrayRow < CrayContainer

  def initialize fish,pdf,table,model=nil
    @table = table
    @color = 'CCCCFF'
    @spans = []
    @model = model
    super fish,pdf
  end

  def label label
    append :content => label, :background_color => @color
  end

  def text text
    append :content => text, :background_color => 'ffffff'
  end

  def span
    @spans << @raw.size
  end

  def field *args
    label = ''
    value = ''
    if args.first.kind_of? Symbol
      raise "you must use row_for(model) to reference with symbols" unless @model
      label = I18n.t args.first, :scope => [:activerecord, :attributes, @model.class.name.underscore.to_sym], :default => args.first.to_s.titleize
      value = @model.respond_to?(args.first) ? @model.send(args.first) : @model[args.first]
    else
      label = args.first[:label]
      value = args.first[:value]
    end
    self.label label
    text value
  end

  def draw text
    if @table.kind_of? CrayForm
      @table.append [ { :content => @table.pdf.make_table([raw], :width => 540) } ], :spans => @spans
    else
      @table.append raw
    end
  end

end

