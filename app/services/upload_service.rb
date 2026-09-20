class UploadService
  EXT_BY_TYPE = {
    "application/pdf" => "pdf",
    "image/jpeg" => "jpg",
    "image/png" => "png",
    "image/webp" => "webp",
    "image/heic" => "heic"
  }.freeze

  MAX_CHUNK_BYTES  = 2.megabytes   # decoded size of one chunk
  MAX_CHUNKS       = 20            # index must be 0..19
  MAX_FILE_BYTES   = 10.megabytes  # total size of one file
  STALE_AFTER      = 1.hour        # abandoned uploads get deleted after this
  UPLOAD_ID_FORMAT = /\A[a-zA-Z0-9\-]{1,64}\z/

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
      upload_id = validate_upload_id!(upload_id)
      idx = parse_index!(index)

      raise ArgumentError, "invalid data" unless data_b64.is_a?(String)
      raise ArgumentError, "chunk too large" if data_b64.bytesize > max_b64_bytes

      buf = Base64.decode64(data_b64)
      raise ArgumentError, "empty chunk" if buf.empty?
      raise ArgumentError, "chunk too large" if buf.bytesize > MAX_CHUNK_BYTES

      ensure_dirs!
      cleanup_stale! if rand < 0.02

      dir = tmp_dir.join(upload_id)
      FileUtils.mkdir_p(dir)
      chunk_path = dir.join(idx.to_s.rjust(6, "0"))

      existing_total = dir.children.reject { |c| c == chunk_path }.sum(&:size)
      raise ArgumentError, "file too large" if existing_total + buf.bytesize > MAX_FILE_BYTES

      File.binwrite(chunk_path, buf)
    end

    def complete(upload_id, file_name, content_type)
      upload_id = validate_upload_id!(upload_id)
      ext = EXT_BY_TYPE[content_type.to_s]
      raise ArgumentError, "unsupported file type" unless ext

      dir = tmp_dir.join(upload_id)
      raise ArgumentError, "no chunks found" unless dir.directory?

      chunks = dir.children.sort_by { |c| c.basename.to_s.to_i }
      raise ArgumentError, "no chunks found" if chunks.empty?
      unless chunks.each_with_index.all? { |c, i| c.basename.to_s.to_i == i }
        raise ArgumentError, "missing chunks"
      end
      raise ArgumentError, "file too large" if chunks.sum(&:size) > MAX_FILE_BYTES

      ensure_dirs!
      cleanup_stale!

      file_id = SecureRandom.uuid
      final_path = files_dir.join("#{file_id}.#{ext}")
      File.open(final_path, "wb") do |out|
        chunks.each { |chunk| IO.copy_stream(chunk.to_s, out) }
      end

      unless signature_ok?(final_path, content_type)
        FileUtils.rm_f(final_path)
        raise ArgumentError, "file content does not match declared type"
      end

      size = final_path.size
      SecureFile.create!(
        id: file_id,
        original_name: sanitize_name(file_name),
        content_type: content_type,
        ext: ext,
        size: size,
        path: final_path.to_s,
        created_at: Time.current
      )
      { file_id: file_id, size: size }
    ensure
      FileUtils.rm_rf(dir) if dir
    end

    # Deletes temp upload folders that were abandoned.
    def cleanup_stale!
      return unless tmp_dir.directory?

      tmp_dir.children.each do |d|
        FileUtils.rm_rf(d) if d.mtime < STALE_AFTER.ago
      end
    end

    private

    def max_b64_bytes
      (MAX_CHUNK_BYTES * 4 / 3) + 8
    end

    def validate_upload_id!(id)
      id = id.to_s
      raise ArgumentError, "invalid uploadId" unless id.match?(UPLOAD_ID_FORMAT)

      id
    end

    def parse_index!(index)
      idx = Integer(index.to_s, 10)
      raise ArgumentError, "invalid index" unless idx >= 0 && idx < MAX_CHUNKS

      idx
    rescue ArgumentError, TypeError
      raise ArgumentError, "invalid index"
    end

    def sanitize_name(name)
      base = File.basename(name.to_s.scrub).gsub(/[^\w.\- ]/, "_").strip
      base.presence&.slice(0, 120) || "file"
    end

    # Checks the real file bytes, not the type the client claimed.
    def signature_ok?(path, content_type)
      head = File.binread(path, 12).to_s.b

      case content_type
      when "application/pdf"
        head.start_with?("%PDF-".b)
      when "image/jpeg"
        head.start_with?("\xFF\xD8\xFF".b)
      when "image/png"
        head.start_with?("\x89PNG\r\n\x1A\n".b)
      when "image/webp"
        head.bytesize >= 12 && head.byteslice(0, 4) == "RIFF".b && head.byteslice(8, 4) == "WEBP".b
      when "image/heic"
        head.bytesize >= 12 && head.byteslice(4, 4) == "ftyp".b
      else
        false
      end
    end
  end
end
