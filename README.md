# Crayfish

PDF templating for Rails.
Crayfish basically translates HTML to PDF.
The idea is that you can use your existing view helpers in your PDF's.
The HTML support is quite limited at the moment.

You can also use the prawn API in your templates.

## Installation

``` ruby
gem install crayfish
```

Prawn havent been gemified for a while, so you need our latest snapshot.  
Add this to your Gemfile:

``` Ruby
gem 'prawn', :git => 'git://github.com/teknobingo/prawn.git', :branch => 'master'
```

## Example (say app/views/main/show.pdf.crayfish):

``` html
<table>
 <tr>
  <th colspan = "6" align = "center" style="background-color:#aaffaa">Time Table</th>
 </tr>
 <tr>
  <th rowspan = "6" style="background-color:#aaffaa">Hours</th>
  <th style="background-color:#ffaaaa">Mon</th>
  <th style="background-color:#ffaaaa">Tue</th>
  <th style="background-color:#ffaaaa">Wed</th>
  <th style="background-color:#ffaaaa">Thu</th>
  <th style="background-color:#ffaaaa">Fri</th>
 </tr>
 <tr>
  <td>Science</td>
  <td>Maths</td>
  <td>Science</td>
  <td>Maths</td>
  <td>Arts</td>
 </tr>
 <tr>
  <td>Social</td>
  <td>History</td>
  <td>English</td>
  <td>Social</td>
  <td>Sports</td>
 </tr>
 <tr>
  <th colspan = "5" align = "center">Lunch</th>
 </tr>
 <tr>
  <td>Science</td>
  <td>Maths</td>
  <td>Science</td>
  <td>Maths</td>
  <td rowspan = "2">Project</td>
 </tr>
 <tr>
  <td>Social</td>
  <td>History</Td>
  <td>English</td>
  <td>Social</td>
 </tr>
</table>
```

Which gives you a single paged PDF looking like this:

![](http://github.com/patrickhno/crayfish/raw/master/doc/example.png) 

You can also use Prawn directly:

``` Ruby
<% table [
  [
    { :content => 'Permit', :background_color => color},
    make_table([['                ', { :content => 'Time', :background_color => color}]])],
  [{ :content => 'Cash',               :background_color => color},  ''],
  [{ :content => 'Organizer',          :background_color => color}, 'Crayfish'],
  [ { :content => make_table([
    [
      { :content => 'Location',  :background_color => color}, location[:name],
      { :content => 'Zip Code',  :background_color => color}, location[:zip_code],
      { :content => 'City',      :background_color => color}, location[:city]]
    ]), :colspan => 2
    }
  ]
], :width => 540
%>
```

## License

(The MIT License)

Copyright (c) 2012 Bingoentreprenøren AS  
Copyright (c) 2012 Patrick Hanevold

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the ‘Software’), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED ‘AS IS’, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
