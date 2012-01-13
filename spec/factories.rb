Factory.sequence(:voter_id) { |n| "BA2864B5-AB35-42A8-8A24-BA878B33#{1000 + n}" }

Factory.define :registration do |f|
  f.voter_id { Factory.next(:voter_id) }
end
