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

	# This example is EvoSynth's interpretation of DeJong and Potter's CCGA presented in
	# "A Cooperative Coevolutionary Approach to Function Optimization" (1994)

	module CCGAExample

		VALUE_BITS = 16
		DIMENSIONS = 5
		MAX_EVALUATIONS = 25000
		POPULATION_SIZE = 25

		def CCGAExample.fitness_function(xs)
			EvoSynth::Problems::FloatBenchmarkFuntions.rosenbrock(xs)
		end

		class CCGABenchmarkEvaluator < EvoSynth::Evaluator

			def initialize(populations)
				super()
				@populations = populations
			end

			def decode(individual, random = false)
				values = (0..DIMENSIONS-1).to_a
				values.each do |index|
					to_decode = if index == individual.population_index
						individual.genome
					elsif random
						@populations[index][EvoSynth.rand(@populations[index].size)].genome
					else
						@populations[index].best.genome
					end

					values[index] = EvoSynth::Decoder.binary_to_real(to_decode, -5.12, 5.12)
				end
				values
			end

			def calculate_fitness(individual)
				CCGAExample.fitness_function(decode(individual))
			end

		end

		class CCGA2BenchmarkEvaluator < CCGABenchmarkEvaluator

			def calculate_fitness(individual)
				best_individual = CCGAExample.fitness_function(decode(individual))
				rand_individual = CCGAExample.fitness_function(decode(individual, true))

				individual.compare_fitness_values(best_individual, rand_individual) == 1 ? best_individual : rand_individual
			end

		end

		class CCGAIndividual < EvoSynth::MinimizingIndividual
			attr_accessor :population_index

			def initialize(population_index, *args)
				@population_index = population_index
				super(*args)
			end
		end

		def CCGAExample.create_configuration(evaluator)
			populations = (0 .. DIMENSIONS - 1).to_a
			populations.map! do |dim|
				EvoSynth::Population.new(POPULATION_SIZE) do
					CCGAIndividual.new(dim, EvoSynth::ArrayGenome.new(VALUE_BITS) { EvoSynth.rand_bool })
				end
			end

			EvoSynth::Configuration.new(
				:mutation					=> EvoSynth::Mutations::BinaryMutation.new(EvoSynth::Mutations::Functions::FLIP_BOOLEAN),
				:parent_selection			=> EvoSynth::Selections::FitnessProportionalSelection.new,
				:recombination				=> EvoSynth::Recombinations::KPointCrossover.new(2),
				:recombination_probability	=> 0.6,
				:populations				=> populations,
				:evaluator					=> evaluator.new(populations)
			)
		end

		def CCGAExample.run(evolver, configuration, evolver_name)
			logger = EvoSynth::Logger.create(50, true, :gen) do |log|
				log.add_column("generations", ->{ evolver.generations_computed })
				log.add_column("evaluations", ->(evolver) { configuration.evaluator.called })
				log.add_column("fitness",     ->(evolver) { best_genome = evolver.best_solution?.map { |individual| EvoSynth::Decoder.binary_to_real(individual.genome, -5.12, 5.12) }
															CCGAExample.fitness_function(best_genome)
														})
			end
			evolver.add_observer(logger)

			puts "\nRunning #{evolver}..."
			puts
			result = evolver.run_while { configuration.evaluator.called < MAX_EVALUATIONS }
			puts "\n#{configuration.evaluator}"

			puts "\n#{evolver_name}: best 'combined' individual:"
			best = result.map { |pop| puts "\t#{pop.best}"; pop.best }
			best_genome = best.map { |individual| EvoSynth::Decoder.binary_to_real(individual.genome, -5.12, 5.12) }

			puts "\n#{evolver_name}: best 'combined' genome:"
			puts "\t#{best_genome.inspect}"
			puts "\n\tfitness = #{CCGAExample.fitness_function(best_genome)}"
			puts
		end

		puts "# --- CCGA-1 ----------------------------------------------------------------------------------- #"

		configuration = create_configuration(CCGABenchmarkEvaluator)
		evolver = EvoSynth::Evolvers::RoundRobinCoevolutionary.new(configuration)
		run(evolver, configuration, "CCGA-1")

		puts "# --- CCGA-2 ----------------------------------------------------------------------------------- #"

		configuration = create_configuration(CCGA2BenchmarkEvaluator)
		evolver = EvoSynth::Evolvers::RoundRobinCoevolutionary.new(configuration)
		run(evolver, configuration, "CCGA-2")
	end
end