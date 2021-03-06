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
#require 'profile'

module Examples
	module MaxOnes

		GENOME_SIZE = 50
		POP_SIZE = 25
		MAX_EVALUATIONS = 5000

		# this is just for the sake of demonstration stuff - you could also use
		# EvoSynth::Problems::BinaryBenchmarkFuntions.count_ones()

		class MaxOnesEvaluator < EvoSynth::Evaluator
			def calculate_fitness(individual)
				individual.genome.inject(0.0) { |fitness, gene| fitness += gene ? 1 : 0 }
			end
		end

		def MaxOnes.create_individual
			EvoSynth::MaximizingIndividual.new( EvoSynth::ArrayGenome.new(GENOME_SIZE) { EvoSynth.rand_bool } )
		end

		configuration = EvoSynth::Configuration.new do |conf|
			conf.individual	= MaxOnes.create_individual
			conf.population	= EvoSynth::Population.new(POP_SIZE) { MaxOnes.create_individual }
			conf.evaluator  = MaxOnes::MaxOnesEvaluator.new
			conf.mutation   = EvoSynth::Mutations::BinaryMutation.new(EvoSynth::Mutations::Functions::FLIP_BOOLEAN)
		end

		# ---------------------------- Use simple Hillclimber ---------------------------- #

		evolver = EvoSynth::Evolvers::Hillclimber.new(configuration)
		logger = EvoSynth::Logger.create(500, true, :gen, :best_fitness, :worst_fitness)
		evolver.add_observer(logger)

		puts "\nRunning Hillclimber...\n"
		result = evolver.run_while { configuration.evaluator.called < MAX_EVALUATIONS }
		puts "\nIndividual after evolution:  #{configuration.individual}"

		# --------------------------- Use GA with weak elistism --------------------------- #

		configuration.evaluator.reset_counters

		evolver = EvoSynth::Evolvers::GeneticAlgorithm.new(configuration)
		EvoSynth::Evolvers.add_weak_elistism(evolver)
		logger = EvoSynth::Logger.create(50, true, :gen, :best_fitness, :worst_fitness, :pop_diversity_dist_hamming, :pop_diversity_entropy)
		evolver.add_observer(logger)

		puts "\nRunning Genetic Algorithm with elitism...\n"
		result = evolver.run_while { configuration.evaluator.called < MAX_EVALUATIONS }
		puts "\nBest Individual after evolution:  #{result.best}"
	end
end