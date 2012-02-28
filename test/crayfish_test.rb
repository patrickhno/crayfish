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
          {:content => 'zip_code', :background_color => 'CCCCFF'},
          {:content => '',         :background_color => 'ffffff'},
          {:content => 'city',     :background_color => 'CCCCFF'},
          {:content => '',         :background_color => 'ffffff'}
        ]
      ], {:width => 540})

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

  # Prawn barfs no matter what!! How to widen the max width?
  #test "basic_form" do
  #  @view.send(:form,%Q{
  #    Aplles %c{    }x%c{    } boxes                | =%c{         }
  #    Pears %c{       }+ bananas%c{       }         | =%c{         }
  #  }, :title => 'Fruits %c{      }')
  #end

end
