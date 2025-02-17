require "tempfile"

module ControllerMacros
  def get_admin
    admins = User.where(administrator: true)
    admins.offset(rand(admins.count)).first
  end

  def get_instructor
    instructorCUDs = CourseUserDatum.joins(:user).where("users.administrator" => false,
                                                        :instructor => true)
    instructorCUDs.offset(rand(instructorCUDs.count)).first.user
  end

  def get_instructor_by_cid(cid)
    instructorCUDs = CourseUserDatum.where(course_id: cid, instructor: true)
    instructorCUDs.offset(rand(instructorCUDs.count)).first.user
  end

  def get_first_cid_by_uid(uid)
    CourseUserDatum.where(user_id: uid).first.course_id
  end

  def get_first_cud_by_uid(uid)
    CourseUserDatum.where(user_id: uid).first.id
  end

  def get_first_aid_by_cud(cud)
    AssessmentUserDatum.where(course_user_datum_id: cud).first.assessment_id
  end

  def create_scheduler_with_cid(cid)
    # Prepare the updater script for scheduler to run
    update_script_path = Rails.root.join("tmp/testscript.rb")
    File.open(update_script_path, "w") do |f|
      f.write("module Updater def self.update(foo) 0 end end")
    end
    s = Course.find(cid).scheduler.new(action: "tmp/testscript.rb",
                                       interval: 86_400, next: Time.zone.now)
    s.save
    s
  end

  def create_course_att_with_cid(cid)
    # Prepare course attachment file
    course_att_file = Rails.root.join("attachments/testattach.txt")
    File.open(course_att_file, "w") do |f|
      f.write("Course attachment file")
    end
    att = Attachment.new(course_id: cid, assessment_id: nil,
                         name: "att#{cid}",
                         released: true)

    att.file = Rack::Test::UploadedFile.new(
      Rails.root.join("attachments/#{File.basename(course_att_file)}"),
      "text/plain",
      Tempfile.new("attach.tmp")
    )
    att.save
    att
  end
end
