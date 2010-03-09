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
	module Evolvers

		# MEMETISCHER-ALGORITHMUS (Weicker Page 165)
		# see also: http://en.wikipedia.org/wiki/Memetic_algorithm for later improvments

		class MemeticAlgorithm
			include EvoSynth::Evolvers::Evolver

			DEFAULT_CHILD_FACTOR = 0.5
			DEFAULT_RECOMBINATION_PROBABILITY = 1.0
			DEFAULT_RECOMBINATION = EvoSynth::Recombinations::KPointCrossover.new(2)
			DEFAULT_INDIVIDUAL_LEARNING_GOAL = ->(gen, best) { gen >= 10 }
			DEFAULT_INDIVIDUAL_LEARNING_PROBABILITY = 0.75
			DEFAULT_SELECTION = EvoSynth::Selections::FitnessProportionalSelection.new
			DEFAULT_SUBEVOLVER_CREATOR = ->(profile) { EvoSynth::Evolvers::LocalSearch.new(profile) }

			def initialize(profile)
				init_profile :population,
					:evaluator,
				    :mutation,
					:recombination						=> DEFAULT_RECOMBINATION,
					:parent_selection					=> DEFAULT_SELECTION,
					:enviromental_selection				=> DEFAULT_SELECTION,
					:child_factor						=> DEFAULT_CHILD_FACTOR,
					:recombination_probability			=> DEFAULT_RECOMBINATION_PROBABILITY,
				    :subevolver_creator					=> DEFAULT_SUBEVOLVER_CREATOR,
					:individual_learning_goal			=> DEFAULT_INDIVIDUAL_LEARNING_GOAL,
					:individual_learning_probability	=> DEFAULT_INDIVIDUAL_LEARNING_PROBABILITY

				use_profile profile

				@population.each { |individual| @evaluator.calculate_and_set_initial_fitness(individual) }
			end

			def to_s
				"memetic algoritm"
			end

			def best_solution
				@population.best
			end

			def worst_solution
				@population.worst
			end

			def return_result
				@population
			end

			def next_generation
				selected_population = @parent_selection.select(@population, @population.size * @child_factor)
				child_population = EvoSynth::Population.new

				selected_population.each_index do |index_one|
					index_two = (index_one + 1) % selected_population.size

					if EvoSynth.rand < @recombination_probability
						child_one, child_two = @recombination.recombine(selected_population[index_one], selected_population[index_two])
					else
						child_one = selected_population[index_one]
						child_two = selected_population[index_two]
					end

					child_population.add(@mutation.mutate(child_one))
					child_population.add(@mutation.mutate(child_two))
				end

				child_population.map! do |child|
					if EvoSynth.rand < @individual_learning_probability
						@profile.individual = child
						subevolver = @subevolver_creator.call(@profile)
						subevolver.run_until &@individual_learning_goal
					else
						child
					end
				end

				child_population.each { |individual| @evaluator.calculate_and_set_fitness(individual) }
				@population = @enviromental_selection.select(child_population, @population.size)
			end

		end

	end
end