import React from 'react';
import clsx from 'clsx';
import BrowserOnly from '@docusaurus/BrowserOnly';

import {
  NavbarSecondaryMenuFiller,
  ThemeClassNames,
} from '@docusaurus/theme-common';
import { useNavbarMobileSidebar } from '@docusaurus/theme-common/internal';
import DocSidebarItems from '@theme/DocSidebarItems';
import ContextSwitcher from '@site/src/components/ContextSwitcher';

// eslint-disable-next-line react/function-component-definition
const DocSidebarMobileSecondaryMenu = ({ sidebar, path }) => {
  const mobileSidebar = useNavbarMobileSidebar();
  const getRouteBasePath = () => {
    const [, doc] = window.location.pathname.split('/');
    if (['docs', '', 'guides'].includes(doc)) return 'default';
    return doc;
  };
  return (
    <BrowserOnly>
      {() => (
        <ul className={clsx(ThemeClassNames.docs.docSidebarMenu, 'menu__list')}>
          {/* customize */}
          <div>
            {/* {getRouteBasePath() === 'Default' || getRouteBasePath() === 'about' ? null : ( */}
            {getRouteBasePath() === 'about' ? null : (
              <BrowserOnly>
                {() => (
                  <div className="my-4 flex items-center justify-end px-4">
                    <ContextSwitcher className="flex-[3]" />
                  </div>
                )}
              </BrowserOnly>
            )}
          </div>
          <DocSidebarItems
            items={sidebar}
            activePath={path}
            onItemClick={(item) => {
              // Mobile sidebar should only be closed if the category has a link
              if (item.type === 'category' && item.href) {
                mobileSidebar.toggle();
              }
              if (item.type === 'link') {
                mobileSidebar.toggle();
              }
            }}
            level={1}
          />
        </ul>
      )}
    </BrowserOnly>

  );
};
function DocSidebarMobile(props) {
  return (
    <NavbarSecondaryMenuFiller
      component={DocSidebarMobileSecondaryMenu}
      props={props}
    />
  );
}
export default React.memo(DocSidebarMobile);
