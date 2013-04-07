module Imgurr
  class Numbers
    class << self
      def to_human(number)
        units = %W(B KiB MiB GiB TiB)

        size, unit = units.reduce(number.to_f) do |(fsize, _), utype|
          fsize > 512 ? [fsize / 1024, utype] : (break [fsize, utype])
        end
        return "#{"%.3f" % size} #{unit}"
      end
    end
  end
end