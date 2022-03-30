DESCRIPTION = "Support for locales and encodings"

inherit packagegroup

LOC_ENC_SUPPORT_PACKAGES = " \
    glibc-gconv-utf-16 \
    glibc-charmap-utf-8 \
    glibc-gconv-cp1255 \
    glibc-charmap-cp1255 \
    glibc-gconv-utf-32 \
    glibc-gconv-utf-7 \
    glibc-gconv-euc-jp \
    glibc-gconv-iso8859-1 \
    glibc-gconv-iso8859-15 \
    glibc-charmap-invariant \
    glibc-localedata-translit-cjk-variants \
    locale-base-tr-tr \
    locale-base-lt-lt \
    locale-base-ja-jp.euc-jp \
    locale-base-fa-ir \
    locale-base-ru-ru \
    locale-base-de-de \
    locale-base-hr-hr \
    locale-base-el-gr \
    locale-base-fr-fr \
    locale-base-es-es \
    locale-base-en-gb \
    locale-base-en-us \
    locale-base-pl-pl \
    locale-base-pl-pl.iso-8859-2 \
"

RDEPENDS_${PN} = "${LOC_ENC_SUPPORT_PACKAGES}"
