require 'test_helper'

describe EdamamApiWrapper do

  describe "self.num_recipes" do
    it "Returns the total number of recipes matching given search term" do
      chicken = { name: "chicken", num: 88393 }
      portabella = { name: "portabella mushrooms", num: 673 }

      VCR.use_cassette("num_recipes") do
        num_recipes = EdamamApiWrapper.num_recipes(chicken[:name])
        num_recipes.must_equal chicken[:num]
      end

      VCR.use_cassette("num_recipes") do
        num_recipes = EdamamApiWrapper.num_recipes(portabella[:name])
        num_recipes.must_equal portabella[:num]
      end
    end

    it "Returns 0 if search term is gibberish or blank" do
      bad_queries = [nil, "", "   ", "lkj"]

      VCR.use_cassette("num_recipes") do
        bad_queries.each do |query|
          num_recipes = EdamamApiWrapper.num_recipes(query)
          num_recipes.must_equal 0, "#{query} should return 0 results"
        end
      end
    end

    it "Returns nil for broken request" do
      VCR.use_cassette("num_recipes") do
        bad_auth = EdamamApiWrapper.num_recipes("pot roast", id: "bogus", key: "bogus")
        bad_auth.must_be_nil
      end
    end

  end

  describe "list_recipes" do

    it "Can return a list of recipes" do
      VCR.use_cassette("list_recipes") do
        recipes = EdamamApiWrapper.list_recipes("chicken")

        recipes.must_be_instance_of Array
        recipes.length.must_equal 100 # this is the limit for free api

        recipes.each do |recipe|
          recipe.must_be_instance_of Recipe
        end
      end
    end

    it "Returns [] if request is broken" do
      VCR.use_cassette("list_recipes") do
        bad_request = EdamamApiWrapper.list_recipes("broccoli", id: "bogus", key: "bad")
        bad_request.must_equal []
      end
    end

    it "Can return a list of recipes in spanish" do
      VCR.use_cassette("spanish_list_recipes") do
        recetas = EdamamApiWrapper.list_recipes("pollo", spanish: true)

        recetas.must_be_instance_of Array
        recetas.length.must_equal 100

        recetas.each do |receta|
          receta.must_be_instance_of Recipe
        end
      end
    end

  end

end
