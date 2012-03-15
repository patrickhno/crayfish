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

class HtmlTest < ActiveSupport::TestCase

  def setup
    @html = ::Crayfish::Html.new(nil,nil)
  end

  test "compile img" do
    img = stub('html img')
    img.stubs(:name).returns(:img)
    img.stubs(:attributes).returns({ 'src' => OpenStruct.new(:value => '/some url')})
    assert_equal @html.compile(img), :image=>"app/some url"
  end

  test "compile empty td" do
    td = stub('html td')
    td.stubs(:name).returns(:td)
    td.stubs(:children).returns([])
    td.stubs(:attributes).returns({})
    row = []
    @html.compile(td,'/td','',:tr => row)
    assert_equal row,[{:content => ''}]
  end

  test "compile td with text" do
    text = stub('text')
    text.stubs(:name).returns(:text)
    text.stubs(:content).returns('test')
    text.stubs(:children).returns([])

    td = stub('html td')
    td.stubs(:name).returns(:td)
    td.stubs(:children).returns([ text ])
    td.stubs(:attributes).returns({})
    row = []
    @html.compile(td,'/td','',:tr => row)
    assert_equal row,[{:content => 'test'}]
  end

end
