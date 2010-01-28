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


require 'set'
require 'evosynth'


module Partitionproblem


	class PartitionFitnessCalculator
		include EvoSynth::Core::FitnessCalculator

		def calculate_fitness(individual)
			sum_a = individual.partition_a.inject(0) { |sum, n| sum + n }
			sum_b = individual.partition_b.inject(0) { |sum, n| sum + n }
			(sum_a - sum_b).abs
		end

	end


	# We've to carefully overwrite functions here!

	class PartitionIndividual < EvoSynth::Core::MinimizingIndividual

		attr_accessor :partition_a, :partition_b

		def initialize(partition_a, partition_b)
			@partition_a = partition_a;
			@partition_b = partition_b;
			@fitness = Float::MAX
		end

		def fitness=(value)
			@fitness = value
			@partition_a.changed = false
			@partition_b.changed = false
		end

		def changed?
			@partition_a.changed? || @partition_b.changed?
		end

		def deep_clone
			my_clone = self.clone
			my_clone.partition_a = self.partition_a.clone
			my_clone.partition_b = self.partition_b.clone
			my_clone
		end

		def to_s
			"partition individual <fitness = #{fitness}, partition_a.size = #{@partition_a.size}, partition_b.size = #{@partition_b.size}>"
		end

	end

	class PartitionMutation

		def mutate(individual)
			mutated = individual.deep_clone
			part_a, part_b = mutated.partition_a, mutated.partition_b

			if rand(2) > 0
				part_a << part_b.delete_at(rand(part_b.size)) unless mutated.partition_b.empty?
			else
				part_b << part_a.delete_at(rand(part_a.size)) unless mutated.partition_a.empty?
			end

			mutated
		end

		def to_s
			"custom made mutation for the partition problem"
		end

	end


	module Testdata

		def Testdata.gen_tiny_set
			problem = Array.new(25)
			problem.fill { |i| i }
		end

		def Testdata.gen_layer_set
			problem = Set.new
			problem.add(rand(1000) * rand(1000)) while problem.size < 200
			problem.add(rand(1000)) while problem.size < 1000
			problem.to_a
		end

		def Testdata.gen_standard_set
			problem = Array.new
			1000.times { |i| problem.insert(-1, i)  }
			problem
		end

		def Testdata.gen_random_set
			problem = Set.new
			problem.add(rand(1000000)) while problem.size < 1000
			problem.to_a
		end

		def Testdata.gen_big_set
			problem = Set.new
			problem.add(rand(10000) * 100) while problem.size < 1000
			problem.to_a
		end
	end

	def Partitionproblem.get_new_individual_from(problem)
		border = rand(problem.size)
		part_a, part_b = EvoSynth::Core::ArrayGenome.new, EvoSynth::Core::ArrayGenome.new

		problem.size.times do
			|index| index < border ? part_a << problem[index] : part_b << problem[index]
		end

		Partitionproblem::PartitionIndividual.new(part_a, part_b)
	end

	POPULATION_SIZE = 10
	GENERATIONS = 1000

	problem = Partitionproblem::Testdata.gen_layer_set
	base_population = EvoSynth::Core::Population.new(POPULATION_SIZE) { Partitionproblem.get_new_individual_from(problem) }

	profile = Struct.new(:individual, :mutation, :selection, :recombination, :population, :fitness_calculator).new
	profile.individual = Partitionproblem.get_new_individual_from(problem)
	profile.mutation = PartitionMutation.new
	profile.selection = EvoSynth::Selections::TournamentSelection.new(3)
	profile.recombination = EvoSynth::Recombinations::Identity.new
	profile.fitness_calculator = Partitionproblem::PartitionFitnessCalculator.new

	puts "Starting with the following population:"
	puts "\tbest individual: #{base_population.best.fitness}"
	puts "\tworst individual: #{base_population.worst.fitness}"
	puts

	profile.population = base_population.deep_clone
	EvoSynth::Util.run_algorith_with_benchmark(EvoSynth::Algorithms::Hillclimber.new(profile), POPULATION_SIZE * GENERATIONS)

	EvoSynth::Algorithms.constants.each do |algorithm|
		algorithm_class = EvoSynth::Algorithms.const_get(algorithm)
		next unless defined? algorithm_class.new
		next if algorithm_class == EvoSynth::Algorithms::Hillclimber

		profile.population = base_population.deep_clone
		EvoSynth::Util.run_algorith_with_benchmark(algorithm_class.new(profile), GENERATIONS) rescue next
	end

end

