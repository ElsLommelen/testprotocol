FROM rocker/verse
ARG BUILD_DATE
ARG VCS_REF
LABEL org.label-schema.build-date=$BUILD_DATE \
org.label-schema.name="RStable" \
org.label-schema.description="A docker image with stable versions of R and a bunch of packages used to check and publish protocols." \
org.label-schema.license="MIT" \
org.label-schema.url="e.g. https://www.inbo.be/" \
org.label-schema.vcs-ref=$VCS_REF \
org.label-schema.vcs-url="https://github.com/inbo/protocolsource" \
org.label-schema.vendor="Research Institute for Nature and Forest" \
maintainer="Hans Van Calster <hans.vancalster@inbo.be>"

## for apt to be noninteractive
ENV DEBIAN_FRONTEND noninteractive
ENV DEBCONF_NONINTERACTIVE_SEEN true

## Consolidated apt-get installations
RUN apt-get update \
  && apt-get install -y --no-install-recommends \
    nano \
    openssh-client \
    libv8-dev \
    ghostscript \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

## Install pandoc
RUN wget https://github.com/jgm/pandoc/releases/download/3.2/pandoc-3.2-1-amd64.deb \
  && dpkg -i pandoc-3.2-1-amd64.deb \
  && rm pandoc-3.2-1-amd64.deb

## Copy R profile
COPY docker/Rprofile.site $R_HOME/etc/Rprofile.site


## Install R packages
RUN R -e "install.packages('renv', repos = c(CRAN = 'https://cloud.r-project.org'))"
RUN R -e "renv::consent(provided = TRUE)"
COPY renv.lock renv.lock
RUN R -e "renv::restore()"
RUN R -e "renv::install(c('reactable', 'zen4R', 'keyring', 'slickR'))"
RUN R -e "renv::isolate()"

## Install tex packages
## tinytex package is already in renv.lock, so will be available
RUN R -e "tinytex::is_tinytex()"
RUN R -e "tinytex::uninstall_tinytex(force = TRUE)"
RUN R -e "tinytex::install_tinytex()"
RUN R -e 'tinytex::tlmgr_install(c("amsmath", "amssymb", "array", "babel-dutch", "babel-english", "babel-french", "beamer", "beamerarticle", "biblatex", "bookmark", "booktabs", "calc", "caption", "csquotes", "dvips", "etoolbox", "fancyvrb", "fontenc", "fontspec", "footnote", "footnotehyper", "geometry", "graphicx", "helvetic", "hyperref", "hyphen-dutch", "hyphen-french", "iftex", "inconsolata", "inputenc", "listings", "lmodern", "longtable", "luatexja-preset", "luatexja-fontspec", "mathspec", "microtype", "multirow", "natbib", "orcidlink", "parskip", "pgfpages", "scrreprt", "selnolig", "setspace", "soul", "svg", "tex", "textcomp", "times", "unicode-math", "upquote", "url", "xcolor", "xeCJK", "xurl"))'


## Copy entrypoint scripts
COPY docker/entrypoint_website.sh /entrypoint_website.sh
COPY docker/entrypoint_update.sh /entrypoint_update.sh
COPY docker/entrypoint_check.sh /entrypoint_check.sh
COPY docker/test_docker.sh /test_docker.sh

## Set default entrypoint
ENTRYPOINT ["/entrypoint_check.sh"]
