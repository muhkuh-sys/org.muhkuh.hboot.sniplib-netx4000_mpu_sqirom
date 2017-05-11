# -*- coding: utf-8 -*-


#----------------------------------------------------------------------------
#
# Set up the Muhkuh Build System.
#
SConscript('mbs/SConscript')
Import('atEnv')


# Create a build environment for the ARM9 based netX chips.

# Create a build environment for the Cortex-R7 and Cortex-A9 based netX chips.
env_cortexR7 = atEnv.DEFAULT.CreateEnvironment(['gcc-arm-none-eabi-4.9', 'asciidoc'])
env_cortexR7.CreateCompilerEnv('NETX4000_RELAXED', ['arch=armv7', 'thumb'], ['arch=armv7-r', 'thumb'])


# Build the platform libraries.
SConscript('platform/SConscript')



#----------------------------------------------------------------------------
#
# Create the compiler environments.
#
astrIncludePaths = ['src', '#platform/src', '#platform/src/lib', '#targets/version']

env_netx4000_default = atEnv.NETX4000_RELAXED.Clone()
env_netx4000_default.Append(CPPPATH = astrIncludePaths + ['src/netx4000'])
env_netx4000_default.Replace(BOOTBLOCK_CHIPTYPE = 4000)

Export('env_netx4000_default')


#----------------------------------------------------------------------------
# This is the list of sources. The elements must be separated with whitespace
# (i.e. spaces, tabs, newlines). The amount of whitespace does not matter.
sources_enable_sqirom = """
	src/netx4000/mpu_enable_sqirom.S
"""

#----------------------------------------------------------------------------
#
# Build Enable SQIROM
#
# netX4000 CR7
env_netx4000_cr7 = env_netx4000_default.Clone()
env_netx4000_cr7.Replace(LDFILE = 'src/netx4000/netx4000_cr7.ld')
src_netx4000_cr7 = env_netx4000_cr7.SetBuildPath('targets/netx4000_cr7', 'src', sources_enable_sqirom)
elf_netx4000_cr7 = env_netx4000_cr7.Elf('targets/netx4000_cr7/netx4000_cr7.elf', src_netx4000_cr7)
txt_netx4000_cr7 = env_netx4000_cr7.ObjDump('targets/netx4000_cr7/netx4000_cr7.txt', elf_netx4000_cr7, OBJDUMP_FLAGS=['--disassemble', '--source', '--all-headers', '--wide'])
bin_netx4000_cr7 = env_netx4000_cr7.ObjCopy('targets/netx4000_cr7/netx4000_cr7.bin', elf_netx4000_cr7)
tmp_netx4000_cr7 = env_netx4000_cr7.GccSymbolTemplate('targets/netx4000_cr7/snippet.xml', elf_netx4000_cr7, GCCSYMBOLTEMPLATE_TEMPLATE='templates/hboot_snippet.xml', GCCSYMBOLTEMPLATE_BINFILE=bin_netx4000_cr7[0])

# Create the snippet from the parameters.
global PROJECT_VERSION
aArtifactGroupReverse = ['org', 'muhkuh', 'hboot', 'sniplib']
atSnippet = {
    'group': '.'.join(aArtifactGroupReverse),
    'artifact': 'netx4000_mpu_sqirom',
    'version': PROJECT_VERSION,
    'vcs_id': env_netx4000_cr7.Version_GetVcsIdLong(),
    'vcs_url': env_netx4000_cr7.Version_GetVcsUrl(),
    'license': 'GPL-2.0',
    'author_name': 'Muhkuh team',
    'author_url': 'https://github.com/muhkuh-sys',
    'description': 'Update the MPU configuration to allow code execution from SQIROM area.',
    'categories': ['netx4000', 'hardware configuration', 'mpu']
}
strArtifactPath = 'targets/snippets/%s/%s/%s' % ('/'.join(aArtifactGroupReverse), atSnippet['artifact'], PROJECT_VERSION)
snippet_netx4000_cr7 = env_netx4000_cr7.HBootSnippet('%s/%s-%s.xml' % (strArtifactPath, atSnippet['artifact'], PROJECT_VERSION), tmp_netx4000_cr7, PARAMETER=atSnippet)

# Create the POM file.
tPOM = env_netx4000_cr7.POMTemplate('%s/%s-%s.pom' % (strArtifactPath, atSnippet['artifact'], PROJECT_VERSION), 'templates/pom.xml', POM_TEMPLATE_GROUP=atSnippet['group'], POM_TEMPLATE_ARTIFACT=atSnippet['artifact'], POM_TEMPLATE_VERSION=atSnippet['version'], POM_TEMPLATE_PACKAGING='xml')

