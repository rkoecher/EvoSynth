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

	# All mutations of EvoSynth should be inside this Module. The given individual has to provide a <i>deep_clone</i> method,
	# which clones the individual and its genome.
	#
	# No mutation should change the given individual.

	module Mutations
	end
end

require 'evosynth/operators/mutations/flip_functions'
require 'evosynth/operators/mutations/one_gene_flipping'
require 'evosynth/operators/mutations/binary_mutation'
require 'evosynth/operators/mutations/efficient_binary_mutation'
require 'evosynth/operators/mutations/identity'
require 'evosynth/operators/mutations/shifting_mutation'
require 'evosynth/operators/mutations/mixing_mutation'
require 'evosynth/operators/mutations/exchange_mutation'
require 'evosynth/operators/mutations/inversion_mutation'
require 'evosynth/operators/mutations/gauss_mutation'
require 'evosynth/operators/mutations/uniform_real_mutation'
require 'evosynth/operators/mutations/self_adaptive_gauss_mutation'