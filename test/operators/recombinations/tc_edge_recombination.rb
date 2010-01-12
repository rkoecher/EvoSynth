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


require 'shoulda'

require 'evosynth'
require 'test/test_util/test_helper'

class EdgeRecombinationTest < Test::Unit::TestCase

	context "a edge recombination run on example genome (Weicker page 133)" do

		setup do
			@recombination = EvoSynth::Recombinations::EdgeRecombination.new

			@individual_one = TestGenomeIndividual.new([1,4,8,6,5,7,2,3])
			@individual_two = TestGenomeIndividual.new([1,2,3,4,8,5,6,7])
		end

		context "before the edge recombination is executed" do

			should "individual one should contain all numbers from 1 to 7" do
				[1,2,3,4,5,6,7,8].each { |item| assert @individual_one.genome.include? item }
			end

			should "individual two should contain all numbers from 1 to 7" do
				[1,2,3,4,5,6,7,8].each { |item| assert @individual_two.genome.include? item }
			end

		end

		context "after the edge recombination is executed" do

			setup do
				@child_one, @child_two = @recombination.recombine(@individual_one, @individual_two)
			end

			should "parent one should (still) contain all numbers from 1 to 7" do
				[1,2,3,4,5,6,7,8].each { |item| assert @individual_one.genome.include? item }
			end

			should "parent two should (still) contain all numbers from 1 to 7" do
				[1,2,3,4,5,6,7,8].each { |item| assert @individual_two.genome.include? item }
			end

			should "both children should (still) contain all numbers from 1 to 7" do
				[1,2,3,4,5,6,7,8].each { |item| assert @child_one.genome.include? item }
				[1,2,3,4,5,6,7,8].each { |item| assert @child_two.genome.include? item }
				puts @individual_one
				puts @individual_two
				puts "========"
				puts @child_one
				puts @child_two
				puts
			end

		end

	end

end