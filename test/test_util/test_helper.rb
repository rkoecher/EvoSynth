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


require 'evosynth'


# TODO: how could this be done in a good way?
# maybe I should do this in evosynth.rb?
# (see also max_ones.rb!)

class TrueClass
	def flip
		!self
	end
end

class FalseClass
	def flip
		!self
	end
end

class TestIndividual
	attr_accessor :fitness

	def initialize(fitness = 0.0)
		@genome = EvoSynth::ArrayGenome.new
		@fitness = fitness
	end

	def calculate_fitness
		@fitness
	end

	def to_s
		@fitness
	end
end


class TestMinimizingIndividual < TestIndividual
	include EvoSynth::MinimizingIndividual
end


class TestMaximizingIndividual < TestIndividual
	include EvoSynth::MaximizingIndividual
end


# FIXME: replace this with a mocked object!

class TestBinaryIndividual
	include EvoSynth::MinimizingIndividual

	def initialize(genome_size)
		@genome = EvoSynth::ArrayGenome.new(genome_size)
	end

	def fitness
		@fitness
	end

	def to_s
		"#{@fitness} - #{@genome}"
	end
end

class TestGenomeIndividual
	include EvoSynth::MinimizingIndividual

	def initialize(genes)
		@fitness = 0
		@genome = EvoSynth::ArrayGenome.new(genes)
	end

	def fitness
		@fitness
	end

	def to_s
		"#{@fitness} - #{@genome}"
	end
end