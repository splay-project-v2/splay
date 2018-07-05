
local misc=require"splay.misc"
local benc=require"splay.benc"

assert(benc)
assert(benc.decode(benc.encode("some input"))=="some input")

--Benchmark benc's encode/decode

function test_encode(data)
	return benc.encode(data)
end

data_sizes={1000,10000,100000,1000000}

print("Bench nested arrays with growing-size string")
for k,v in pairs(data_sizes) do
	
	local gen= misc.gen_string(v)
	for i=1,(v/100) do -- to avoid stackoverlow
		gen={gen}
	end
	
	start=misc.time()
	enc_data=test_encode(gen)
	print((v/1000).."K", misc.to_dec_string(misc.time()-start))
end
