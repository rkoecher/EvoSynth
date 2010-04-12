#	Copyright (c) 2009, 2010 Yves Adler <yves.adler@googlemail.com>
#
#	Permission is hereby granted, free of charge, to any person
#	obtaining a copy of this software and associated documentation
#	files (the "Software"), to deal in the Software without
#	restriction, including without limitation the rights to use,
#	copy, modify, merge, publish, distribute, sublicense, and/or sell
#	copies of the Software, and to permit persons to whom the
#	Software is furnished to do so, subject to the following
#	conditions:
#
#	The above copyright notice and this permission notice shall be
#	included in all copies or substantial portions of the Software.
#
#	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#	EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
#	OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
#	NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
#	HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
#	WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
#	FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
#	OTHER DEALINGS IN THE SOFTWARE.


module EvoSynth
	module Output

		# exports the contents (data) of a logger to gnuplot

		class GnuplotExporter

			def GnuplotExporter.export(logger, gpscript, datafile, pngfile, title = '')

				File.open(gpscript,  "w+") do |file|
					file.write("# Gnuplot script generated by EvoSynth - feel free to modify\n")
					file.write("\nset terminal png")
					file.write("\nset output '#{pngfile}'")
					file.write("\nset title \"#{title}\"")

					#reset
					#set terminal png
					#set   autoscale                        # scale axes automatically
					#unset     log                          # remove any log-scaling
					#unset     label                        # remove any previous labels
					##set yrange [0:150]
					#set xrange [0:1000]
					#set xtic auto                          # set xtics automatically
					#set ytic auto                          # set ytics automatically
					#set xlabel "Generation"
					#set ylabel "Farben"

					logger.data.column_names.each_with_index do |column, index|
						if index == 0
							file.write("\nplot \"#{datafile}\"")
						else
							file.write(", \\\n\t\"\"")
						end
						file.write(" using 1:#{index + 2}")
						file.write(" title \"#{column}\"")
						file.write(" with lines")
					end
				end

				File.open(datafile,  "w+") do |file|
					file.write("# counter")
					logger.data.column_names.each { |column| file.write("\t#{column}") }

					logger.data.each_row do |row_number, row|
						file.write("\n#{row_number}")
						row.each { |column| file.write("\t#{column}")}
					end
				end

				begin
					`gnuplot #{gpscript}`
				rescue
					puts "WARNING: could not find Gnuplot executeable"
				end
			end

		end

	end
end