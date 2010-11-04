module Joey
  class User < Profile
    include ParserHelpers

    define_properties :first_name, :last_name, :middle_name, :link, :about, :about_me, :birthday, :gender,
      :email, :website, :timezone, :updated_time, :verified, :religion, :political
    define_properties :pic_small, :pic_big, :pic_square, :pic, :pic_big_with_logo, :pic_small_with_logo,
      :pic_square_with_logo, :pic_with_logo, :picture
    define_properties :is_app_user, :books, :username, :significant_other_id, :meeting_for, :tv, :meeting_sex, :relationship_status
    define_properties :wall_count, :uid, :movies, :sex, :birthday_date, :notes_count, :activities, :profile_blurb, :music, :locale
    define_properties :profile_url, :profile_update_time, :interests, :is_blocked, :quotes, :interested_in, :bio
    define_properties :start_time # Hack to check if it is an event

    def self.recognize?(hash)
      !hash.has_key?("category")
    end

    hash_populating_accessor :status, "Status"
    hash_populating_accessor :work, "Work"
    hash_populating_accessor :work_history, "WorkHistory"
    hash_populating_accessor :education, "Education"
    hash_populating_accessor :education_history, "EducationHistory"

    hash_populating_accessor :location, "Page"
    hash_populating_accessor :current_location, "Location"
    hash_populating_accessor :hometown, "Page"
    hash_populating_accessor :hometown_location, "Location"
    hash_populating_accessor :hs_info, "HsInfo"
    hash_populating_accessor :affiliations, "Affiliation"
    hash_populating_accessor :family, "Relative"

    #has_association :activities,"Activity"
    has_association :friends, "User"
    has_association :home, "Post"
    #has_association :interests, "Interest"
    #has_association :music, "Music"
    #has_association :books, "Book"
    #has_association :movies, "Movie"
    has_association :television, "Television"
    has_association :likes, "Page"

    def has_app_permission?(ext_perm)
      boolianize(client.rest_call("users.hasAppPermission", :ext_perm => ext_perm.to_s))
    end

    def friends!(ids)
      data = self.client.rest_call('users.getInfo', :uids => ids, :fields =>
                                   'about_me,activities,affiliations,books,birthday,birthday_date,current_location,education_history,
                                                 email,family,first_name,hometown_location,hs_info,interests,is_app_user,is_blocked,last_name,
                                                 locale,meeting_for,meeting_sex,movies,music,name,notes_count,pic,pic_big,pic_small,pic_square,
                                                 pic_with_logo,pic_big_with_logo,pic_small_with_logo,pic_square_with_logo,
                                                 political,profile_blurb,profile_update_time,profile_url,quotes,relationship_status,religion,sex,
                                                 significant_other_id,status,timezone,tv,username,wall_count,website,work_history')
     self.client.map_data(data, self.class)
    end

    def info(args)
      data = self.client.rest_call('users.getInfo', :uids => self.id, :fields => args.join(','))
      user = self.client.map_data(data, self.class).first
      user.id = self.id
      user
    end

    def validate
      errors << { :message => 'id should not be nil' } if id.nil?
      errors << { :message => "name should be string but is #{name.inspect}" } unless name.is_a?(String)
      errors << { :message => "gender should be 'male' or 'female' but is #{gender.inspect}" } unless ['male', 'female', nil].include?(gender)
      errors << { :message => "pic big is neither string nor nil but is #{pic_big.inspect}" } unless pic_big.is_a?(String) || pic_big.nil?
      errors << { :message => "current location is neither Joey::Location nor nil but is #{current_location.inspect}" } unless current_location.is_a?(Joey::Location) || current_location.nil?
      errors << { :message => "Facebook is an idiot. This is an event instead of a Joey::User or Joey::Page" } unless start_time.nil?
      # updated_time.to_time rescue errors << { :message => 'updated_time is not compatible' }
    end

    def valid?
      self.validate
      puts self.errors.inspect unless self.errors.empty?
      self.errors.empty?
    end
  end
end
