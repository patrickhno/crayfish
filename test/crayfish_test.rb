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

require 'test_helper'
require 'action_controller'
require 'action_view'

class CrayfishTest < ActiveSupport::TestCase

  class Response
    def content_type
      'pdf'
    end

    def content_type= val
    end

    def headers
      @headers ||= {}
    end
  end

  class ActionController
    include Crayfish::ActionController

    def response
      @response ||= Response.new
    end

    def headers
      response.headers
    end
  end

  class ActionView
    include Crayfish::ActionView

    def controller
      @controller ||= ActionController.new
    end
  end

  def setup
    @view = ActionView.new
    @view.send(:setup)
  end

  test "setup" do
    @view = ActionView.new
    @view.send(:setup)
  end

  test "table" do

    sub_table = @view.make_table([['                ', { :content => 'Label4'}]])

    @view.instance_variable_get('@pdf').expects(:table).with(
      [
        [{:content => 'Label'}, sub_table],
        [{:content => 'label2'}, ''],
        [{:content => 'Label3'}, 'hello']
      ], {:width => 540})

    @view.send(:table,[
      [{ :content => 'Label'}, sub_table],
      [{ :content => 'label2'}, ''],
      [{ :content => 'Label3'}, 'hello'],
    ], :width => 540)
  end

  test "table block with rows" do
    @view.instance_variable_get('@pdf').expects(:table).with(
      [
        [
          {:content => 'Label1',   :background_color => 'CCCCFF'},
          {:content => '    ',     :background_color => 'ffffff'},
          {:content => 'Label2',   :background_color => 'CCCCFF'},
          {:content => '    ',     :background_color => 'ffffff'}
        ], [
          {:content => 'Label3',   :background_color => 'CCCCFF'},
          {:content => '    ',     :background_color => 'ffffff'}
        ], [
          {:content => 'Label4',   :background_color => 'CCCCFF'},
          {:content => 'foo',      :background_color => 'ffffff'}
        ], [
          {:content => 'Label5',   :background_color => 'CCCCFF'},
          {:content => 'Hello',    :background_color => 'ffffff'},
          {:content => 'Zip Code', :background_color => 'CCCCFF'},
          {:content => '0000',     :background_color => 'ffffff'},
          {:content => 'City',     :background_color => 'CCCCFF'},
          {:content => 'Internet', :background_color => 'ffffff'}
        ]
      ], {:width => 540}
    )

    location = { :name => 'Hello', :zip_code => '0000', :city => 'Internet'}
    @view.send(:table) do |t| 
       t.row do |r| 
         r.label 'Label1'; r.span; r.text '    ' 
         r.field :label => 'Label2', :value => '    ' 
       end 
       t.row do |r| 
         r.label 'Label3';  r.span; r.text '    ' 
       end 
       t.row do |r| 
         r.label 'Label4';          r.span; r.text 'foo'
       end 
       t.row_for location do |r| 
         r.field :label => 'Label5' , :value => location[:name]
         r.field :zip_code 
         r.field :city 
       end
    end
  end

  test "view delegates basic form to CrayForm" do

    text = %Q{
      Aplles %c{    }x%c{    } boxes                | =%c{         }
      Pears %c{       }+ bananas%c{       }         | =%c{         }
    }

    form = mock('CrayFrom')
    form.expects(:heading).with('Fruits %c{      }')
    form.expects(:form_body).with(text, :title => 'Fruits %c{      }')
    form.expects(:draw).with('')
    Crayfish::CrayForm.expects(:new).with(
      instance_of(CrayfishTest::ActionView),
      instance_of(Prawn::Document),
      :title => 'Fruits %c{      }', :span => /\|/, :element => /%c{[^}]*}/
    ).returns(form)

    @view.send(:form,text, :title => 'Fruits %c{      }')
  end

  test "CrayForm's form_body" do

    text = %Q{
      Apples %c{    }x%c{    } boxes                | =%c{         }
      Pears %c{       }+ bananas%c{       }         | =%c{         }
    }

    pdf   = mock('Prawn::Document')
    font  = mock('Prawn::Font')
    table = mock('Prawn::Table')
    pdf.expects(:cursor).at_least_once.returns(0)

    pdf.expects(:make_table).once.with do |table,options|
      table.kind_of?(Array) &&
      options == {:width => 540, :cell_style => {:padding => [0, 0, 0, 0], :border_width => 1}}
    end.returns(table)

    pdf.expects(:make_table).with do |tab,options|
      tab.kind_of?(Array) && tab.size == 2 &&
      tab[0].size == 2 &&
      tab[1].size == 2 &&
      tab[0][0] == table &&
      tab[0][1] == table &&
      tab[1][0] == table &&
      tab[1][1] == table &&
      options == {:width => 540, :cell_style => {:padding => [11, 0, 11, 0], :borders => []}}
    end.returns(table)

    pdf.expects(:make_table).with do |table,options|
      table.kind_of?(Array) && table.size == 1 &&
      table.first.size == 2 &&
      table.first.select{ |cell| cell.kind_of?(Crayfish::CellHelper) }.size == 2 &&
      table.first[0].content == 'Fruits ' &&
      table.first[1].content == ''        &&
      options == {:cell_style => {:borders => []}}
    end.returns(table)

    pdf.expects(:make_table).with do |table,options|
      table.kind_of?(Array) && table.size == 1 &&
      table.first.size == 6 &&
      table.first.select{ |cell| cell.kind_of?(Crayfish::CellHelper) }.size == 6 &&
      table.first[0].content == 'Apples '                  &&
      table.first[1].content == ''                         &&
      table.first[2].content == 'x'                        &&
      table.first[3].content == ''                         &&
      table.first[4].content == ' boxes                '   &&
      table.first[5].content == ''                         &&
      options == {:cell_style => {:borders => []}}
    end.returns(table)

    pdf.expects(:make_table).with do |table,options|
      table.kind_of?(Array) && table.size == 1 &&
      table.first.size == 6 &&
      table.first.select{ |cell| cell.kind_of?(Crayfish::CellHelper) }.size == 6 &&
      table.first[0].content == 'Pears '      &&
      table.first[1].content == ''            &&
      table.first[2].content == '+ bananas'   &&
      table.first[3].content == ''            &&
      table.first[4].content == '         '   &&
      table.first[5].content == ''            &&
      options == {:cell_style => {:borders => []}}
    end.returns(table)

    pdf.expects(:make_table).with do |table,options|
      table.kind_of?(Array) && table.size == 1 &&
      table.first.size == 2 &&
      table.first.select{ |cell| cell.kind_of?(Crayfish::CellHelper) }.size == 2 &&
      table.first[0].content == ' =' &&
      table.first[1].content == ''   &&
      options == {:cell_style => {:borders => []}}
    end.returns(table)

    pdf.expects(:make_table).with do |tab,options|
      tab.kind_of?(Array) && tab.size == 1 &&
      tab.first.size == 1 &&
      tab.first[0] == table &&
      options == {:width => 540, :cell_style => {:padding => [0, 0, 0, 0], :borders => []}}
    end.returns(table)

    pdf.expects(:make_table).with do |table,options|
      table.kind_of?(Array) && table.size == 1 &&
      table.first.size == 2 &&
      table.first.select{ |cell| cell.kind_of?(Crayfish::CellHelper) }.size == 2 &&
      table.first[0].content == ' =' &&
      table.first[1].content == ''   &&
      options == {:cell_style => {:borders => []}}
    end.returns(table)

    pdf.expects(:font).at_least_once.returns(font)
    pdf.expects(:fill_color).with('CCCCFF')
    pdf.expects(:fill)
    pdf.expects(:fill_color).with('000000')

    view  = mock('Crayfish::ActionView')
    view.expects(:flush).at_least_once

    font.expects(:line_gap).returns(5)
    font.expects(:descender).returns(6)

    table.expects(:draw)

    form = Crayfish::CrayForm.new(view,pdf,:title => 'Fruits %c{      }', :span => /\|/, :element => /%c{[^}]*}/)
    form.heading 'Fruits %c{      }'
    form.send(:form_body,text, :title => 'Fruits %c{      }')
    form.draw ''

  end

end
