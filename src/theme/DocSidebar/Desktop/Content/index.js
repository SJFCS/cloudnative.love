import React, { useState } from 'react';
import clsx from 'clsx';
import { ThemeClassNames } from '@docusaurus/theme-common';
import ContextSwitcher from '@site/src/components/ContextSwitcher';
import BrowserOnly from '@docusaurus/BrowserOnly';

import {
  useAnnouncementBar,
  useScrollPosition,
} from '@docusaurus/theme-common/internal';
import { translate } from '@docusaurus/Translate';
import DocSidebarItems from '@theme/DocSidebarItems';
import styles from './styles.module.css';
function useShowAnnouncementBar() {
  const { isActive } = useAnnouncementBar();
  const [showAnnouncementBar, setShowAnnouncementBar] = useState(isActive);
  useScrollPosition(
    ({ scrollY }) => {
      if (isActive) {
        setShowAnnouncementBar(scrollY === 0);
      }
    },
    [isActive],
  );
  return isActive && showAnnouncementBar;
}


export default function DocSidebarDesktopContent({ path, sidebar, className }) {
  const showAnnouncementBar = useShowAnnouncementBar();

  //doc hide
  const getRouteBasePath = () => {
    const [, doc] = window.location.pathname.split('/');
    if (['docs', '', 'guides'].includes(doc)) return 'default';
    return doc;
  };
  return (
    <BrowserOnly>
      {() => (
        <nav
          aria-label={translate({
            id: 'theme.docs.sidebar.navAriaLabel',
            message: 'Docs sidebar',
            description: 'The ARIA label for the sidebar navigation',
          })}
          className={clsx(
            'menu thin-scrollbar',
            styles.menu,
            showAnnouncementBar && styles.menuWithAnnouncementBar,
            className,
          )}>
          {/* customize */}
          <div>
            {/* {getRouteBasePath() === 'Default' || getRouteBasePath() === 'about' ? null : ( */}
            {getRouteBasePath() === 'about' ? null : (
              <div className="my-4 flex items-center justify-end px-4">
                <ContextSwitcher className="flex-[3]" />
              </div>
            )}
          </div>
          <ul className={clsx(ThemeClassNames.docs.docSidebarMenu, 'menu__list')}>
            <DocSidebarItems items={sidebar} activePath={path} level={1} />
          </ul>
        </nav>
      )}
    </BrowserOnly>

  );
}
