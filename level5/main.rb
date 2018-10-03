require 'json'
require 'date'
require 'pry'

filepath = 'data/input.json'

def parsing_data(filepath)
  serialized_data = File.read(filepath)
  parsing_data = JSON.parse(serialized_data)
  return $cars = parsing_data['cars'], $rentals = parsing_data['rentals'], $options = parsing_data['options']
end

def book_a_car(filepath)
  parsing_data(filepath)
  rental_hash = match_rental_car($cars, $rentals)
  p rental_hash
  rental_hash["options"] = match_option_rental($options, $rentals)

  # p rental_hash["options"]

end

def match_rental_car(cars, rentals)
  rentals_array = []
  cars.each do |car|
    rentals.select do |rental|
      rental_hash = booking_rental(car, rental, $options) if rental['car_id'] == car['id']
      rentals_array << rental_hash
    end
  end
  output_rentals_array = rentals_array.select{ |el| el != nil }
  transform_in_json(output_rentals_array)
end

def match_option_rental(options, rentals)
  options_array = []
  rentals.each do |rental|
    options.select do |option|
      option['rental_id'] == rental['id']
      options_array << option['type']
    end
      p options_array
  end
end


def booking_rental(car, rental, options)
  rental_hash = Hash.new
  distance_component = distance_component(car, rental)
  number_of_rental_days = rental_days(rental).to_i + 1
  time_component = time_component(car, number_of_rental_days)

  # calculate prices
  rental_price = total_price(distance_component, time_component)
  commission_amount = commission(rental_price)
  insurance_fee = insurance_fee(commission_amount)
  assistance_fee = assistance_fee(number_of_rental_days)
  drivy_fee = drivy_fee(commission_amount, insurance_fee, assistance_fee)
  owner_fee = rental_price - commission_amount
  actions_array = actions_hashes(rental_price, owner_fee, insurance_fee, assistance_fee, drivy_fee)
  rental_hash['id'] = rental['id']
  rental_hash["actions"] = actions_array
  rental_hash
end

def actions_hashes(rental_price, owner_fee, insurance_fee, assistance_fee, drivy_fee)
  actions_array = []
  driver_hash = action_hash("driver", "debit", rental_price)
  owner_hash = action_hash("insurance", "credit", owner_fee)
  insurance_hash = action_hash("assistance", "credit", insurance_fee)
  assistance_hash = action_hash("drivy", "credit", assistance_fee)
  drivy_hash = action_hash("owner", "credit", drivy_fee)
  actions_array << driver_hash
  actions_array << owner_hash
  actions_array << insurance_hash
  actions_array << assistance_hash
  actions_array << drivy_hash
end

def action_hash(who, type, amount)
  {
    "who": who,
    "type": type,
    "amount": amount.ceil
  }
end



def total_price(distance_component, time_component)
  distance_component + time_component
end

def commission(rental_price)
  0.3 * rental_price
end

def insurance_fee(commission_amount)
  commission_amount / 2
end

def assistance_fee(number_of_rental_days)
  number_of_rental_days * 100
end


def drivy_fee(commission_amount, insurance_fee, assistance_fee)
  commission_amount - insurance_fee - assistance_fee
end


def rental_days(rental)
  Date.parse(rental['end_date']) - Date.parse(rental['start_date'])
end

def time_component(car, number_of_rental_days)
  decrease_pricing(number_of_rental_days, car)
end

def decrease_pricing(number_of_rental_days, car)
  car_price_per_day = car['price_per_day']
  ten_perc_decrease = 1 + 0.9 * (number_of_rental_days - 1)
  thirty_perc_decrease = 1 + 0.7 * (number_of_rental_days - 4)

  return car_price_per_day if number_of_rental_days == 1
  if (1..4).include?(number_of_rental_days)
    car_price_per_day * ten_perc_decrease
  elsif (4..10).include?(number_of_rental_days)
    car_price_per_day * (2.7 + thirty_perc_decrease)
  else
    (car_price_per_day * (1 + 2.7 + 4.2 + (0.5 * (number_of_rental_days - 10))))
  end
end

def distance_component(car, rental)
  car['price_per_km'] * rental['distance']
end

def transform_in_json(output_rentals_array)
  rentals_json = {"rentals": output_rentals_array}
  return rentals_json
end

book_a_car(filepath)
