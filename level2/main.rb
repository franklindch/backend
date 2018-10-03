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
    rentals_array_with_decrease = []
    @cars.each do |car|
      @rentals.select do |rental|
        rental_details = car_rental_match(car, rental) if rental['car_id'] == car['id']
        rentals_array_with_decrease << rental_details
      end
    end
    rentals_array_with_decrease.select { |el| el != nil }
  end

  protected

  def car_rental_match(car, rental)
    rental_details = Hash.new
    distance_component = distance_component(car, rental)
    time_component = time_component(car, rental)
    price_with_decrease = total_price(distance_component, time_component)
    rental_details['id'] = rental['id']
    rental_details['price'] = price_with_decrease.ceil
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
    decrease_pricing(number_of_rental_days, car)
  end

  def distance_component(car, rental)
    car['price_per_km'] * rental['distance']
  end

  def decrease_pricing(number_of_rental_days, car)
    car_price_per_day = car['price_per_day']
    ten_perc_decrease = 1 + 0.9 * (number_of_rental_days - 1)
    thirty_perc_decrease = 1 + 0.7 * (number_of_rental_days - 4)
    if number_of_rental_days == 1
      car_price_per_day
    elsif (1..4).include?(number_of_rental_days)
      car_price_per_day * ten_perc_decrease
    elsif (4..10).include?(number_of_rental_days)
      car_price_per_day * (2.7 + thirty_perc_decrease)
    else
      car_price_per_day * (1 + 2.7 + 4.2 + (0.5 * (number_of_rental_days - 10)))
    end
  end
end

parsed_data = Drivy.parsing_input_data
drivy_data = Drivy.new(cars: parsed_data['cars'], rentals: parsed_data['rentals'])
output_rentals_array_with_decrease = drivy_data.rentals

def to_json(output_rentals_array_with_decrease)
  rentals_json = {"rentals": output_rentals_array_with_decrease}
  p rentals_json.to_json
end

to_json(output_rentals_array_with_decrease)


