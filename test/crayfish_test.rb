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

  def table_contents table
    table.rows(0..-1).map{ |cell|
      if cell.kind_of?(Prawn::Table::Cell::Text)
        cell.content
      elsif cell.kind_of?(Prawn::Table::Cell::Subtable)
        table_contents(cell.subtable)
      elsif cell.kind_of?(Crayfish::CellHelper)
        cell.content
      else
        cell.class.name
      end
    }
  end

  def cell_positions table
    table.rows(0..-1).map{ |cell|
      if cell.kind_of?(Prawn::Table::Cell::Text)
        cell.x
      elsif cell.kind_of?(Prawn::Table::Cell::Subtable)
        cell_positions(cell.subtable)
      elsif cell.kind_of?(Crayfish::CellHelper)
        cell.x
      else
        cell.class.name
      end
    }
  end

  test "CrayForm's form_body" do

    text = %Q{
      Apples %c{    }x%c{    } boxes                | =%c{         }
      Pears %c{       }+ bananas%c{       }         | =%c{         }
    }

    pdf   = Prawn::Document.new()

    view  = mock('Crayfish::ActionView')
    view.expects(:flush).at_least_once

    form = Crayfish::CrayForm.new(view,pdf,:title => 'Fruits %c{      }', :span => /\|/, :element => /%c{[^}]*}/)
    form.heading 'Fruits %c{      }'
    form.send(:form_body,text, :title => 'Fruits %c{      }')
    table = form.draw ''

    assert_equal 3,table.row_length
    assert_equal 1,table.column_length

    assert_equal 1,table.row(0).size
    assert_equal 1,table.row(1).size
    assert_equal 1,table.row(2).size

    assert_equal 1,table.row(0).first.subtable.row_length
    assert_equal 1,table.row(0).first.subtable.column_length

    assert_equal table_contents(table),
      [[["Fruits ", ""]],
       "",
       [["Apples ", "", "x", "", " boxes                ", ""],
        [" =", ""],
        ["Pears ", "", "+ bananas", "", "         ", ""],
        [" =", ""]]]

    # check span alignment
    n=0
    aligned_cells = cell_positions(table).last.select{ |item| n+=1; item if n.even? }.map{ |row| row.last }

    assert_equal 2,aligned_cells.size
    assert_equal 1,aligned_cells.uniq.size

  end

end
