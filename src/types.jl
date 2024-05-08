const eprime_fl_enc = enc"UTF-16LE"

struct EPrimeLogFileHeader
	experiment::String
	session_start_date_time_utc::String
	subject::Int
	session::Int
	level_names::Vector{String}
	misc::AbstractDict
end


struct EPrimeLogFile
	path::String
	content::Vector{String}
    header::EPrimeLogFileHeader
    levels::@NamedTuple{ids::Vector{Int64}, names::Vector{String}}
end


function EPrimeLogFileHeader(file_content::Vector{String})
	hdd = OrderedDict{Symbol, Any}()
	hd_info = _header_info(file_content)
    lvl_names = [x.second for x in hd_info if x.first == :LevelName] # level name vector
	for kv in hd_info
		if kv.first != :LevelName # ignore level names, because we have level name vevtor
			key = unique_key(hdd, kv.first)
			hdd[key] = kv.second
		end
	end

	experiment = pop!(hdd, :Experiment)
	session_start_date_time_utc = pop!(hdd, :SessionStartDateTimeUtc)
	subject = pop!(hdd, :Subject)
	session = pop!(hdd, :Session)
	return EPrimeLogFileHeader(experiment, session_start_date_time_utc,
		subject, session, lvl_names, hdd)
end

EPrimeLogFile(path::AbstractString) = read(EPrimeLogFile, path)

function Base.read(::Type{EPrimeLogFile}, path::AbstractString)
	content = open(path, "r") do fl
		readlines(fl, eprime_fl_enc)
	end
    hd = EPrimeLogFileHeader(content)
    levels = _levels(content, hd.level_names)
	EPrimeLogFile(path, content, hd, levels)
end

function Base.show(io::IO, mime::MIME"text/plain", x::EPrimeLogFile)
	println(io, "EPrimeLogFile")
	hd = x.header
	println(io, "  Experiment: $(hd.experiment), Subject: $(hd.subject), Session: $(hd.session)")
    println(io, "  Levels: $(x.levels.ids) Level names: $(x.levels.names)")

end;

function Base.show(io::IO, mime::MIME"text/plain", x::EPrimeLogFileHeader)
	println(io, "EPrimeLogFileHeader")
	println(io, "  experiment: $(x.experiment)")
	println(io, "  subject: $(x.subject)")
	println(io, "  session: $(x.session)")
	println(io, "  session_start_date_time_utc: $(x.session_start_date_time_utc)")
	println(io, "  level_names: $(x.level_names)")
	println(io, "  misc: ")
	for (k, v) in x.misc
		println(io, "     $(k): $(v)")
	end
end;

## helper
function _header_info(file_content::Vector{String})
	"returns header information as list of pairs (thus, allow for double entries)"
	rtn = Pair[]
	header_section = false
	for l in file_content
		if match(re_header_start, l) != nothing
			header_section = true
		elseif match(re_header_end, l) != nothing
			break
		elseif header_section
			# search level
			kv = key_value(l; varnames_without_dots=true)
			if kv isa Pair
				push!(rtn, kv)
			end
		end
	end
	return rtn
end

function _levels(file_content::Vector{String}, level_names::Vector{String})
    lvl = Set{String}()
    # scan content for all unique levels
    for l in file_content
        x = match(re_level, l)
		if x != nothing
			push!(lvl, x.captures[1])
		end
    end
    ids = sort([parse(Int, x) for x in lvl])
    names = [level_names[x] for x in ids]
    return NamedTuple((:ids => ids, :names => names))
end
