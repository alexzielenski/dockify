# Dockify

**Find the actual library source here: https://github.com/alexzielenski/dockify_library**

A hack that modifies the Dock to work like it did pre-10.8. Allowing old dock themes to be compatible once again (and retina compatible).

## Installation

1. Move Dockify.app to /Applications
2. Open Dockify.app
3. Press the Install button
4. $$$ PROFIT $$$

## Themes

The Dockify app also has a pop up that allows users to choose their desired theme and enable/disable Dockify without uninstalling it. 

Each user manages his or her own theme library and can independently change the theme without affecting other users. Dockify can also be installed on a system with multiple users and only affect one account.

**Themes are stored in *~/Library/Dockify/&lt;theme name&gt;***

### Format

Create a directory with the same name as your theme and place your desired files for the theme within this directory. Files for theming the dock can have thee following names:

<table>
	<thead>
		<tr>
			<th>Filename</th>
			<th>Size</th>
			<th>Description</th>
	</thead>
	<tbody>
		<tr>
			<td>Info.plist</th>
			<td>-</td>
			<td><b>Required</b>: Plist file with format described below about the theme.</td>
		</tr>
		<tr>
			<td>scurve-sm.png</th>
			<td>900 x 128</td>
			<td><b>Required</b>: Smallest representation of the Dock background itself</td>
		</tr>
		<tr>
			<td>scurve-m.png</th>
			<td>1280 x 128</td>
			<td><b>Required</b>: Medium representation of the Dock background itself</td>
		</tr>
		<tr>
			<td>scurve-l.png</th>
			<td>1280 x 98</td>
			<td><b>Required</b>: Used when there are so many items in the Dock that it needs to shrink</td>
		</tr>
		<tr>
			<td>scurve-xl.png</th>
			<td>1280 x 86</td>
			<td><b>Required</b>: There are so many items in the Dock that it needs to be miniscule</td>
		</tr>
		<tr>
			<td>frontline.png</th>
			<td>790 x 3</td>
			<td>Small image at the base, spanning the width of the Dock</td>
		</tr>
		<tr>
			<td>indicator_large.png</th>
			<td>-</td>
			<td>Running Indicator for large-sized docks/td>
		</tr>
		<tr>
			<td>indicator_medium.png</th>
			<td>-</td>
			<td>Running Indicator for medium-sized docks/td>
		</tr>
		<tr>
			<td>indicator_small.png</th>
			<td>-</td>
			<td>Running Indicator for small-sized docks/td>
		</tr>
		<tr>
			<td>separator.png</th>
			<td>64 x 128</td>
			<td>Used to separator Applications and files/trash</td>
		</tr>
	</tbody>
</table>

** Any of the above images can also have a retina representation, simply append @2x after the filename and double the size, similarly to iPhone.

*** All of the images not listed as required will be taken from the Dock's default resources if not present.

### Info.plist

In each theme there is a plist file that contains some metadata about the theme. The Info.plist should have the following self-explanatoy keys:

<table>
	<thead>
		<tr>
			<th>Key</th>
			<th>Type</th>
			<th>Description</th>
	</thead>
	<tbody>
		<tr>
			<td>author</th>
			<td>string</td>
			<td>Author's name</td>
		</tr>
		<tr>
			<td>name</th>
			<td>string</td>
			<td>Theme name</td>
		</tr>
		<tr>
			<td>retinaReady</th>
			<td>boolean</td>
			<td>If your theme supports retina, list true; if not, false</td>
		</tr>
		<tr>
			<td>showFrontLine</th>
			<td>boolean</td>
			<td>True if you want the Dock to show the frontline, otherwise not</td>
		</tr>
		<tr>
			<td>reflectionOpacity</th>
			<td>real</td>
			<td>Decimal value for the desired opacity of Icon Reflections. If not present, the default 31.5 will be used in its stead</td>
		</tr>
		<tr>
			<td>version</th>
			<td>real</td>
			<td>Decimal version of the theme. (Use just one decimal place like 2.3, not 4.5.6)</td>
		</tr>
		<tr>
			<td>website</th>
			<td>string</td>
			<td>URL for any relevant information about the theme</td>
		</tr>
	</tbody>
</table>

***

# EULA

Dockify is software created by Alex Zielenski <http://alexzielenski.com> for fee.

I can't afford a lawyer so here is a EULA in my best law-speak:

* You have the right to use Dockify for free without anyone's permission.
* As a creator of a Dockify theme, you have the right to distribute, sell, license, do anything you want with it within the bounds of any laws that apply to you.
* You are free to distribute Dockify to anyone as long as its resources are unmodified and any relevant copyrights or attributions are retained.
* As a user of Dockify, you are legally obligated to tell your parents "thank you" or a family member that you love them at least once after reading this.

# License

Copyright &copy; 2014 Alex Zielenski

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
