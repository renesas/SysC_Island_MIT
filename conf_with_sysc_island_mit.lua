
function top()
    local str = debug.getinfo(2, "S").source:sub(2)
    if str:match("(.*/)")
    then
        return str:match("(.*/)")
    else
        return "./"
    end
end

function get_default_page_size(arch)
    -- print("Detecting host page size...")
    if arch == "aarch64" then
        -- get the page size of the host
        local handle = io.popen("getconf PAGE_SIZE")
        local page_size = handle:read("*a"):gsub("\n", "")
        handle:close()
        return tonumber(page_size)
    else
        return 0x1000
    end
end

--
print ("Lua config running. . . ");

local shared_mem_path_00;
local shared_mem_size_00;
local shared_mem_path_01;
local shared_mem_size_01;
local dram_mirror00_path;
local dram_mirror00_size;


-- Detect host architecture
local handle = io.popen("uname -m")
local arch = handle:read("*a"):gsub("\n", "") -- Removes newline
handle:close()
-- print("CPU Architecture: " .. arch)

-- Set default page size based on architecture
local default_page_size = get_default_page_size(arch)
-- print("Default page size: " .. default_page_size)

system = {};
system.quantum = 1000000; -- Unit: ps

shared_mem_path_00 = "shared_mem_00_" .. os.getenv("USER") .. ".img";
shared_mem_size_00 = 0x80000; 


SysC_Island_MIT = {};

Memory={};

SysC_Island_MIT.REMOTEPORT = {};

    SysC_Island_MIT.virt_socket_path = "unix:/tmp/qemu-rport-" .. os.getenv("USER") .. "/virt/qemu-rport-_cosim@0";


    SysC_Island_MIT.bus_lenient = true;

    SysC_Island_MIT.pl011 = {in_ = {address=0x3C000000, size=0x00001000}};

    SysC_Island_MIT.uart_term = {};

    SysC_Island_MIT.uart_term.backends = "term";

    Memory.shared_mem_00 = {in_ = {address=0xC1000000, size=0x80000 };shared = shared_mem_path_00}; 






