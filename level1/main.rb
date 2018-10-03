require 'json'
require 'date'

class Drivy
  def initialize(data)
    @cars = data[:cars]
    @rentals = data[:rentals]
  end

  def self.parsing_input_data
    data = 'data/input.json'
    serialized_data = File.read(data)
    JSON.parse(serialized_data)
  end

  def rentals
    rentals_array = []
    @cars.each do |car|
      @rentals.select do |rental|
        rental_details = car_rental_match(car, rental) if rental['car_id'] == car['id']
        rentals_array << rental_details
      end
    end
    rentals_array.select { |el| el != nil }
  end

  protected

  def car_rental_match(car, rental)
    rental_details = Hash.new
    distance_component = distance_component(car, rental)
    time_component = time_component(car, rental)
    price = total_price(distance_component, time_component)
    rental_details['id'] = rental['id']
    rental_details['price'] = price
    rental_details
  end

  def total_price(distance_component, time_component)
    distance_component + time_component
  end

  def rental_days(rental)
    Date.parse(rental['end_date']) - Date.parse(rental['start_date'])
  end

  def time_component(car, rental)
    number_of_rental_days = rental_days(rental).to_i + 1
    car['price_per_day'] * number_of_rental_days
  end

  def distance_component(car, rental)
    car['price_per_km'] * rental['distance']
  end
end


parsed_data = Drivy.parsing_input_data
drivy_data = Drivy.new(cars: parsed_data['cars'], rentals: parsed_data['rentals'])
output_rentals_array = drivy_data.rentals

def to_json(output_rentals_array)
  rentals_json = {"rentals": output_rentals_array}
  p rentals_json.to_json
end

to_json(output_rentals_array)
