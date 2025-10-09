ApplicationRecord.transaction do
  puts "Preparing to seed feedbacks..."
  user = User.first
  unless user
    puts "Error: No users found. Please create one."
    return
  end
  audio_clip_ids = GeneratedAudioClip.pluck(:id)
  
  puts "Destroying existing feedbacks..."
  Feedback.destroy_all

  puts "Seeding 100 sample feedbacks for user: #{user.email}..."

  100.times do |i|
    feedback_type = Feedback.feedback_types.keys.sample
    service_type = Feedback.services.keys.sample
    
    # --- THIS IS THE FIX ---
    # Compare the string from .keys.sample with another string.
    rating = feedback_type == "review" ? rand(1..5) : nil

    comment_length = rand(1500..2500)
    comment = Faker::Lorem.paragraph_by_chars(number: comment_length, supplemental: true)

    associated_audio_clip_id = (audio_clip_ids.any? && rand(0..1).zero?) ? audio_clip_ids.sample : nil

    Feedback.create!(
      user: user,
      feedback_type: feedback_type,
      service: service_type,
      rating: rating,
      comment: comment,
      generated_audio_clip_id: associated_audio_clip_id,
      created_at: Faker::Time.between(from: 1.year.ago, to: Time.now)
    )

    print "." if i % 10 != 0
    if i % 10 == 0 && i > 0
      puts " #{i}..."
    end
  end

  puts "\n...100 feedbacks seeded successfully!"
end