class UploadService
  EXT_BY_TYPE = {
    "application/pdf" => "pdf",
    "image/jpeg" => "jpg",
    "image/png" => "png",
    "image/webp" => "webp",
    "image/heic" => "heic"
  }.freeze

  class << self
    def root
      Rails.root.join("storage", "uploads")
    end

    def tmp_dir
      root.join("tmp")
    end

    def files_dir
      root.join("files")
    end

    def ensure_dirs!
      FileUtils.mkdir_p(tmp_dir)
      FileUtils.mkdir_p(files_dir)
    end

    def write_chunk(upload_id, index, data_b64)
      raise ArgumentError, "invalid uploadId" unless upload_id.match?(/\A[a-zA-Z0-9\-]+\z/)

      ensure_dirs!
      dir = tmp_dir.join(upload_id)
      FileUtils.mkdir_p(dir)
      buf = Base64.decode64(data_b64)
      File.write(dir.join(index.to_s.rjust(6, "0")), buf, mode: "wb")
    end

    def complete(upload_id, file_name, content_type)
      raise ArgumentError, "invalid uploadId" unless upload_id.match?(/\A[a-zA-Z0-9\-]+\z/)

      dir = tmp_dir.join(upload_id)
      raise ArgumentError, "no chunks found" unless dir.directory?

      chunks = dir.children.sort
      raise ArgumentError, "no chunks found" if chunks.empty?

      ext = EXT_BY_TYPE[content_type] || "bin"
      file_id = SecureRandom.uuid
      final_path = files_dir.join("#{file_id}.#{ext}")
      File.open(final_path, "wb") do |out|
        chunks.each { |chunk| out.write(chunk.read(mode: "rb")) }
      end
      FileUtils.rm_rf(dir)

      size = final_path.size
      SecureFile.create!(
        id: file_id,
        original_name: file_name.presence || "file",
        content_type: content_type.presence || "application/octet-stream",
        ext: ext,
        size: size,
        path: final_path.to_s,
        created_at: Time.current
      )
      { file_id: file_id, size: size }
    end
  end
end
